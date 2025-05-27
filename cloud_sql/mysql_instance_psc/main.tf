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

# [START cloud_sql_mysql_instance_psc]
resource "google_sql_database_instance" "default" {
  name             = "mysql-instance"
  region           = "us-central1"
  database_version = "MYSQL_8_0"
  settings {
    tier              = "db-f1-micro"
    availability_type = "REGIONAL"
    backup_configuration {
      enabled            = true
      binary_log_enabled = true
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
# [END cloud_sql_mysql_instance_psc]

# [START cloud_sql_mysql_instance_psc_endpoint]
resource "google_compute_address" "default" {
  name         = "psc-compute-address-${google_sql_database_instance.default.name}"
  region       = "us-central1"
  address_type = "INTERNAL"
  subnetwork   = "default"     # Replace value with the name of the subnet here.
  address      = "10.128.0.43" # Replace value with the IP address to reserve.
}

data "google_sql_database_instance" "default" {
  name = resource.google_sql_database_instance.default.name
}

resource "google_compute_forwarding_rule" "default" {
  name                  = "psc-forwarding-rule-${google_sql_database_instance.default.name}"
  region                = "us-central1"
  network               = "default"
  ip_address            = google_compute_address.default.self_link
  load_balancing_scheme = ""
  target                = data.google_sql_database_instance.default.psc_service_attachment_link
  allow_psc_global_access = true
}
# [END cloud_sql_mysql_instance_psc_endpoint]

# [START cloud_sql_mysql_instance_ipv6_psc_endpoint]
resource "google_compute_forwarding_rule" "ipv6_ilb_example" {
  name   = "ipv6-psc-forwarding-rule-${google_sql_database_instance.default.name}"
  region = "us-central1"

  load_balancing_scheme = ""
  target                = data.google_sql_database_instance.default.psc_service_attachment_link
  all_ports             = true
  network               = "default" # Replace value with the name of the network here.
  subnetwork            = "default" # Replace value with the name of the subnet here.
  ip_version            = "IPV6"
  allow_psc_global_access = true
}
# [END cloud_sql_mysql_instance_ipv6_psc_endpoint]