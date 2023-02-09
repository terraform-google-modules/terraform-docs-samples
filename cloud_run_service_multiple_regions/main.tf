/**
 * Copyright 2022 Google LLC
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

# Cloud Run service replicated across multiple GCP regions

resource "google_project_service" "compute_api" {
  provider                   = google-beta
  service                    = "compute.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "run_api" {
  provider                   = google-beta
  service                    = "run.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# [START cloudrun_multiregion_variables]
variable "domain_name" {
  type    = string
  default = "example.com"
}

variable "run_regions" {
  type    = list(string)
  default = ["us-central1", "europe-west1"]
}
# [END cloudrun_multiregion_variables]

# [START cloudrun_multiregion_addr]
resource "google_compute_global_address" "lb_default" {
  provider = google-beta
  name     = "myservice-service-ip"

  # Use an explicit depends_on clause to wait until API is enabled
  depends_on = [
    google_project_service.compute_api
  ]
}
# [END cloudrun_multiregion_addr]

# [START cloudrun_multiregion_backend]
resource "google_compute_backend_service" "lb_default" {
  provider              = google-beta
  name                  = "myservice-backend"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group           = google_compute_region_network_endpoint_group.lb_default[0].id
  }

  backend {
    group           = google_compute_region_network_endpoint_group.lb_default[1].id
  }

  # Use an explicit depends_on clause to wait until API is enabled
  depends_on = [
    google_project_service.compute_api,
  ]
}
# [END cloudrun_multiregion_backend]

# [START cloudrun_multiregion_urlmap]
resource "google_compute_url_map" "lb_default" {
  provider        = google-beta
  name            = "myservice-lb-urlmap"
  default_service = google_compute_backend_service.lb_default.id

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.lb_default.id
    route_rules {
      priority = 1
      url_redirect {
        https_redirect         = true
        redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
      }
    }
  }
}
# [END cloudrun_multiregion_urlmap]

# [START cloudrun_multiregion_cert]
resource "google_compute_managed_ssl_certificate" "lb_default" {
  provider = google-beta
  name     = "myservice-ssl-cert"

  managed {
    domains = [var.domain_name]
  }
}
# [END cloudrun_multiregion_cert]

# [START cloudrun_multiregion_proxy_https]
resource "google_compute_target_https_proxy" "lb_default" {
  provider = google-beta
  name     = "myservice-https-proxy"
  url_map  = google_compute_url_map.lb_default.id
  ssl_certificates = [
    google_compute_managed_ssl_certificate.lb_default.name
  ]
  depends_on = [
    google_compute_managed_ssl_certificate.lb_default
  ]
}
# [END cloudrun_multiregion_proxy_https]

# [START cloudrun_multiregion_forwarding]
resource "google_compute_global_forwarding_rule" "lb_default" {
  provider              = google-beta
  name                  = "myservice-lb-fr"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_https_proxy.lb_default.id
  ip_address            = google_compute_global_address.lb_default.id
  port_range            = "443"
  depends_on            = [google_compute_target_https_proxy.lb_default]
}
# [END cloudrun_multiregion_forwarding]

# [START cloudrun_multiregion_neg]
resource "google_compute_region_network_endpoint_group" "lb_default" {
  provider              = google-beta
  count                 = length(var.run_regions)
  name                  = "myservice-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.run_regions[count.index]
  cloud_run {
    service = google_cloud_run_service.run_default[count.index].name
  }
}
# [END cloudrun_multiregion_neg]

# [START cloudrun_multiregion_addr]
output "load_balancer_ip_addr" {
  value = google_compute_global_address.lb_default.address
}
# [END cloudrun_multiregion_addr]

# [START cloudrun_multiregion_service]
resource "google_cloud_run_service" "run_default" {
  provider = google-beta
  count    = length(var.run_regions)
  name     = "myservice-run-app-${var.run_regions[count.index]}"
  location = var.run_regions[count.index]

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  # Use an explicit depends_on clause to wait until API is enabled
  depends_on = [
    google_project_service.run_api
  ]
}
# [END cloudrun_multiregion_service]

# [START cloudrun_multiregion_service_iam]
resource "google_cloud_run_service_iam_member" "run_allow_unauthenticated" {
  provider = google-beta
  count    = length(var.run_regions)
  location = google_cloud_run_service.run_default[count.index].location
  service  = google_cloud_run_service.run_default[count.index].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
# [END cloudrun_multiregion_service_iam]

# [START cloudrun_multiregion_urlmap_https]
resource "google_compute_url_map" "https_default" {
  provider = google-beta
  name     = "myservice-https-urlmap"

  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    https_redirect         = true
    strip_query            = false
  }
}
# [END cloudrun_multiregion_urlmap_https]

# [START cloudrun_multiregion_proxy]
resource "google_compute_target_http_proxy" "https_default" {
  provider = google-beta
  name     = "myservice-http-proxy"
  url_map  = google_compute_url_map.https_default.id

  depends_on = [
    google_compute_url_map.https_default
  ]
}
# [END cloudrun_multiregion_proxy]

# [START cloudrun_multiregion_forwarding_https]
resource "google_compute_global_forwarding_rule" "https_default" {
  provider   = google-beta
  name       = "myservice-https-fr"
  target     = google_compute_target_http_proxy.https_default.id
  ip_address = google_compute_global_address.lb_default.id
  port_range = "80"
  depends_on = [google_compute_target_http_proxy.https_default]
}
# [END cloudrun_multiregion_forwarding_https]
