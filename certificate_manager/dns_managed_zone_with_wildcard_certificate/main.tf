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

# [START certificatemanager_dns_managed_zone_with_wildcard_certificate_parent_tag]
locals {
  domain = "example.me"
  name   = "prefixname"
}

resource "random_id" "tf_prefix" {
  byte_length = 4
}

# [START certificatemanager_dns_wildcard_enable_service]
resource "google_project_service" "certificatemanager_svc" {
  service            = "certificatemanager.googleapis.com"
  disable_on_destroy = false
}
# [END certificatemanager_dns_wildcard_enable_service]

# [START certificatemanager_dns_wildcard_dns_managed_zone]
resource "google_dns_managed_zone" "default" {
  name        = "example-mz-${random_id.tf_prefix.hex}"
  dns_name    = "${local.domain}."
  description = "Example DNS zone"
  labels = {
    "terraform" : true
  }
  visibility    = "public"
  force_destroy = true
}
# [END certificatemanager_dns_wildcard_dns_managed_zone]

# [START certificatemanager_dns_wildcard_dns_authorization]
resource "google_certificate_manager_dns_authorization" "default" {
  name        = "${local.name}-dnsauth-${random_id.tf_prefix.hex}"
  description = "The default dns auth"
  domain      = local.domain
  labels = {
    "terraform" : true
  }
}
# [END certificatemanager_dns_wildcard_dns_authorization]

# [START certificatemanager_dns_wildcard_dns_record_set]
resource "google_dns_record_set" "cname" {
  name         = google_certificate_manager_dns_authorization.default.dns_resource_record[0].name
  managed_zone = google_dns_managed_zone.default.name
  type         = google_certificate_manager_dns_authorization.default.dns_resource_record[0].type
  ttl          = 300
  rrdatas      = [google_certificate_manager_dns_authorization.default.dns_resource_record[0].data]
}
# [END certificatemanager_dns_wildcard_dns_record_set]

# [START certificatemanager_dns_wildcard_certificate]
resource "google_certificate_manager_certificate" "root_cert" {
  name        = "${local.name}-rootcert-${random_id.tf_prefix.hex}"
  description = "The wildcard cert"
  managed {
    domains = [local.domain, "*.${local.domain}"]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.default.id
    ]
  }
  labels = {
    "terraform" : true
  }
}
# [END certificatemanager_dns_wildcard_certificate]

# [START certificatemanager_dns_wildcard_map]
resource "google_certificate_manager_certificate_map" "certificate_map" {
  name        = "${local.name}-certmap-${random_id.tf_prefix.hex}"
  description = "${local.domain} certificate map"
  labels = {
    "terraform" : true
  }
}
# [END certificatemanager_dns_wildcard_map]

# [START certificatemanager_dns_wildcard_map_entry_one]
resource "google_certificate_manager_certificate_map_entry" "first_entry" {
  name        = "${local.name}-first-entry-${random_id.tf_prefix.hex}"
  description = "example certificate map entry"
  map         = google_certificate_manager_certificate_map.certificate_map.name
  labels = {
    "terraform" : true
  }
  certificates = [google_certificate_manager_certificate.root_cert.id]
  hostname     = local.domain
}
# [END certificatemanager_dns_wildcard_map_entry_one]

# [START certificatemanager_dns_wildcard_map_entry_two]
resource "google_certificate_manager_certificate_map_entry" "second_entry" {
  name        = "${local.name}-second-entity-${random_id.tf_prefix.hex}"
  description = "example certificate map entry"
  map         = google_certificate_manager_certificate_map.certificate_map.name
  labels = {
    "terraform" : true
  }
  certificates = [google_certificate_manager_certificate.root_cert.id]
  hostname     = "*.${local.domain}"
}
# [END certificatemanager_dns_wildcard_map_entry_two]

output "domain_name_servers" {
  value = google_dns_managed_zone.default.name_servers
}
output "certificate_map" {
  value = google_certificate_manager_certificate_map.certificate_map.id
}
# [END certificatemanager_dns_managed_zone_with_wildcard_certificate_parent_tag]
