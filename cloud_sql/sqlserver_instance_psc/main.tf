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

# [START cloud_sql_sqlserver_instance_psc]
resource "google_sql_database_instance" "default" {
  name             = "sqlserver-instance"
  region           = "us-central1"
  database_version = "SQLSERVER_2019_ENTERPRISE"
  root_password    = "INSERT-PASSWORD-HERE"
  settings {
    tier              = "db-custom-2-7680"
    availability_type = "REGIONAL"
    backup_configuration {
      enabled    = true
      start_time = "20:55"
    }
    ip_configuration {
      psc_config {
        psc_enabled               = true
        allowed_consumer_projects = [] # Add consumer project IDs here.
      }
      ipv4_enabled = false
    }
  }
}
# [END cloud_sql_sqlserver_instance_psc]

# [START cloud_sql_sqlserver_instance_psc_endpoint]
resource "google_compute_address" "default" {
  name         = "psc-compute-address-${google_sql_database_instance.default.name}"
  region       = "us-central1"
  address_type = "INTERNAL"
  subnetwork   = "default"     # Replace value with the name of the subnet here.
  address      = "10.128.0.44" # Replace value with the IP address to reserve.
}

data "google_sql_database_instance" "default" {
  name = resource.google_sql_database_instance.default.name
}

resource "google_compute_forwarding_rule" "default" {
  name                    = "psc-forwarding-rule-${google_sql_database_instance.default.name}"
  region                  = "us-central1"
  network                 = "default"
  ip_address              = google_compute_address.default.self_link
  load_balancing_scheme   = ""
  target                  = data.google_sql_database_instance.default.psc_service_attachment_link
  allow_psc_global_access = true
}
# [END cloud_sql_sqlserver_instance_psc_endpoint]

# [START cloud_sql_sqlserver_instance_ipv6_psc_endpoint]
resource "google_compute_network" "ipv6_default" {
  name                     = "net-ipv6"
  auto_create_subnetworks  = false
  enable_ula_internal_ipv6 = true
}

resource "google_compute_subnetwork" "ipv6_default" {
  name             = "subnet-internal-ipv6"
  ip_cidr_range    = "10.0.0.0/16"
  region           = "us-central1"
  stack_type       = "IPV4_IPV6"
  ipv6_access_type = "INTERNAL"
  network          = google_compute_network.ipv6_default.id
}

resource "google_compute_address" "ipv6_default" {
  name         = "psc-compute-ipv6-address-${google_sql_database_instance.default.name}"
  region       = "us-central1"
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.ipv6_default.name
  ip_version   = "IPV6"
}

resource "google_compute_forwarding_rule" "ipv6_ilb_example" {
  name   = "ipv6-psc-forwarding-rule-${google_sql_database_instance.default.name}"
  region = "us-central1"

  load_balancing_scheme   = ""
  target                  = data.google_sql_database_instance.default.psc_service_attachment_link
  network                 = google_compute_network.ipv6_default.name
  subnetwork              = google_compute_subnetwork.ipv6_default.name
  ip_address              = google_compute_address.ipv6_default.id
  allow_psc_global_access = true
}
# [END cloud_sql_sqlserver_instance_ipv6_psc_endpoint]
