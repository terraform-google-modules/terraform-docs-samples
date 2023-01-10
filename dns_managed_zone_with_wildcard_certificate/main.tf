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

variable "domain" {
  default = "skiski.cloud"
  description = "setup your domain"
}

variable "name" {
  default = "examplename"
  description = "the name prefix for your resources"
}

resource "random_id" "tf_prefix" {
  byte_length = 4
}

resource "google_dns_managed_zone" "default" {
  name        = "example-mz-${random_id.tf_prefix.hex}"
  dns_name    = "${var.domain}."
  description = "Example DNS zone"
  labels = {
    "terraform" : true
  }
  visibility    = "public"
  force_destroy = true
}

resource "google_certificate_manager_dns_authorization" "default" {
  name        = "${var.name}-dnsauth-${random_id.tf_prefix.hex}"
  description = "The default dns auth"
  domain      = var.domain
  labels = {
    "terraform" : true
  }
}

resource "google_dns_record_set" "cname" {
  name         = google_certificate_manager_dns_authorization.default.dns_resource_record[0].name
  managed_zone = google_dns_managed_zone.default.name
  type         = google_certificate_manager_dns_authorization.default.dns_resource_record[0].type
  ttl          = 300
  rrdatas      = [google_certificate_manager_dns_authorization.default.dns_resource_record[0].data]
}

resource "google_certificate_manager_certificate" "root_cert" {
  name        = "${var.name}-rootcert-${random_id.tf_prefix.hex}"
  description = "The wildcard cert"
  managed {
    domains = [var.domain, "*.${var.domain}"]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.default.id
    ]
  }
  labels = {
    "terraform" : true
  }
}

resource "google_certificate_manager_certificate_map" "certificate_map" {
  name        = "${var.name}-certmap-${random_id.tf_prefix.hex}"
  description = "${var.domain} certificate map"
  labels = {
    "terraform" : true
  }
}

resource "google_certificate_manager_certificate_map_entry" "first_entry" {
  name        = "${var.name}-first-entry-${random_id.tf_prefix.hex}"
  description = "example certificate map entry"
  map         = google_certificate_manager_certificate_map.certificate_map.name
  labels = {
    "terraform" : true
  }
  certificates = [google_certificate_manager_certificate.root_cert.id]
  hostname     = var.domain
}

resource "google_certificate_manager_certificate_map_entry" "second_entry" {
  name        = "${var.name}-second-entity-${random_id.tf_prefix.hex}"
  description = "example certificate map entry"
  map         = google_certificate_manager_certificate_map.certificate_map.name
  labels = {
    "terraform" : true
  }
  certificates = [google_certificate_manager_certificate.root_cert.id]
  hostname     = "*.${var.domain}"
}
output "domain_name_servers" {
  value = google_dns_managed_zone.default.name_servers
}
output "certificate_map" {
  value = google_certificate_manager_certificate_map.certificate_map.id
}
