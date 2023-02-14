/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  domain = "example.me"
  name   = "prefixname"
}

resource "random_id" "tf_prefix" {
  byte_length = 4
}

# [START certificatemanager_google_managed_lb_auth_servicess]
resource "google_project_service" "certificatemanager_svc" {
  service            = "certificatemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute_api" {
  service                    = "compute.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}
# [END certificatemanager_google_managed_lb_auth_services]

# [START certificatemanager_google_managed_lb_auth_certificate]
resource "google_certificate_manager_certificate" "default" {
  name        = "${local.name}-rootcert-${random_id.tf_prefix.hex}"
  description = "Cert with LB authorization"
  managed {
    domains = [local.domain]
  }
  labels = {
    "terraform" : true
  }
}
# [END certificatemanager_google_managed_lb_auth_certificate]

# [START certificatemanager_google_managed_lb_auth_map]
resource "google_certificate_manager_certificate_map" "default" {
  name        = "certmap1"
  description = "${local.domain} certificate map"
  labels = {
    "terraform" : true
  }
}
# [END certificatemanager_google_managed_lb_auth_map]

# [START certificatemanager_google_managed_lb_auth_map_entry]
resource "google_certificate_manager_certificate_map_entry" "default" {
  name        = "${local.name}-first-entry-${random_id.tf_prefix.hex}"
  description = "example certificate map entry"
  map         = google_certificate_manager_certificate_map.default.name
  labels = {
    "terraform" : true
  }
  certificates = [google_certificate_manager_certificate.default.id]
  hostname     = local.domain
}
# [END certificatemanager_google_managed_lb_auth_map_entry]

# [START cloudloadbalancing_google_managed_lb_auth_addr]
resource "google_compute_global_address" "default" {
  provider = google-beta
  name     = "myservice-service-ip"

  # Use an explicit depends_on clause to wait until API is enabled
  depends_on = [
    google_project_service.compute_api
  ]
}
# [END cloudloadbalancing_google_managed_lb_auth_addr]

# [START cloudloadbalancing_google_managed_lb_auth_cert]
resource "google_compute_managed_ssl_certificate" "default" {
  name = "myservice-ssl-cert"

  managed {
    domains = [local.domain]
  }
}
# [END cloudloadbalancing_google_managed_lb_auth_cert]

# [START certificatemanager_google_managed_lb_auth_target_https_proxy]

data "google_project" "default" {
}

resource "google_compute_target_https_proxy" "default" {
  name = "test-proxy"

  certificate_map = "//certificatemanager.googleapis.com/projects/${data.google_project.default.project_id}/locations/global/certificateMaps/certmap1"

  url_map = google_compute_url_map.default.id
  ssl_certificates = [
    google_compute_managed_ssl_certificate.default.name
  ]
  depends_on = [
    google_compute_managed_ssl_certificate.default
  ]
}
# [END certificatemanager_google_managed_lb_auth_target_https_proxy]

# [START cloudloadbalancing_google_managed_lb_auth_forwarding]
resource "google_compute_global_forwarding_rule" "default" {
  provider              = google-beta
  name                  = "myservice-lb-fr"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_https_proxy.default.id
  ip_address            = google_compute_global_address.default.id
  port_range            = "443"
  depends_on            = [google_compute_target_https_proxy.default]
}
# [END cloudloadbalancing_google_managed_lb_auth_forwarding]

# [START certificatemanager_google_managed_lb_auth_backend]
resource "google_storage_bucket" "default" {
  name                        = "${random_id.tf_prefix.hex}-bucket-1"
  location                    = "us-east1"
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  // delete bucket and contents on destroy.
  force_destroy = true
}

resource "google_storage_bucket_iam_member" "default" {
  bucket = google_storage_bucket.default.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_compute_backend_bucket" "default" {
  name        = "bucket-1"
  bucket_name = google_storage_bucket.default.name
}
# [END certificatemanager_google_managed_lb_auth_backend]

# [START cloudloadbalancing_google_managed_lb_auth_urlmap_https]
resource "google_compute_url_map" "default" {
  name            = "myservice-https-urlmap"
  default_service = google_compute_backend_bucket.default.id
}
# [END cloudloadbalancing_google_managed_lb_auth_urlmap_https]


output "certificate_map" {
  value = google_certificate_manager_certificate_map.default.id
}

output "load_balancer_ip_addr" {
  value = google_compute_global_address.default.address
}

