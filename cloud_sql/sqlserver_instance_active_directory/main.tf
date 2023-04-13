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

# [START cloud_sql_sqlserver_instance_directory_instance]

# [START vpc_sqlserver_instance_active_directory_network]
resource "google_compute_network" "private_network" {
  name                    = "private-network"
  auto_create_subnetworks = "false"
}
# [END vpc_sqlserver_instance_active_directory_network]

# [START vpc_sqlserver_instance_active_directory_address]
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.private_network.id
}
# [END vpc_sqlserver_instance_active_directory_address]

# [START vpc_sqlserver_instance_active_directory_service_connection]
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.private_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
# [END vpc_sqlserver_instance_active_directory_service_connection]

# [START cloud_sql_sqlserver_instance_active_directory_instance]
resource "google_sql_database_instance" "instance_with_ad" {
  name             = "database-instance-name"
  region           = "us-central1"
  database_version = "SQLSERVER_2019_STANDARD"
  root_password    = "INSERT-PASSWORD-HERE"

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-custom-2-7680"
    active_directory_config {
      domain = "ad.domain.com"
    }
    ip_configuration {
      ipv4_enabled    = "false"
      private_network = google_compute_network.private_network.id
    }
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by 
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}
# [END cloud_sql_sqlserver_instance_active_directory_instance]

# [END cloud_sql_sqlserver_instance_directory_instance]
