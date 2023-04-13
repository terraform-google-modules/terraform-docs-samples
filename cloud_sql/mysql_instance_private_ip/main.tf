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

# [START cloud_sql_mysql_instance_private_ip]

# [START vpc_mysql_instance_private_ip_network]
resource "google_compute_network" "peering_network" {
  name                    = "private-network"
  auto_create_subnetworks = "false"
}
# [END vpc_mysql_instance_private_ip_network]

# [START vpc_mysql_instance_private_ip_address]
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.peering_network.id
}
# [END vpc_mysql_instance_private_ip_address]

# [START vpc_mysql_instance_private_ip_service_connection]
resource "google_service_networking_connection" "default" {
  network                 = google_compute_network.peering_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
# [END vpc_mysql_instance_private_ip_service_connection]

# [START cloud_sql_mysql_instance_private_ip_instance]
resource "google_sql_database_instance" "instance" {
  name             = "private-ip-sql-instance"
  region           = "us-central1"
  database_version = "MYSQL_8_0"

  depends_on = [google_service_networking_connection.default]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = "false"
      private_network = google_compute_network.peering_network.id
    }
  }
  # set `deletion_protection_enabled` flag to true to enable deletion protection of 
  # an instance at the GCP level. Enabling this protection will guard against 
  # accidental deletion across all surfaces (API, gcloud, Cloud Console and Terraform) 
  # by enabling the GCP Cloud SQL instance deletion protection. On the other hand, 
  # `deletion_protection` flag prevents destroy of the resource only when the deletion 
  # is attempted in terraform.
  deletion_protection = false
}
# [END cloud_sql_mysql_instance_private_ip_instance]

# [START cloud_sql_mysql_instance_private_ip_routes]
resource "google_compute_network_peering_routes_config" "peering_routes" {
  peering              = google_service_networking_connection.default.peering
  network              = google_compute_network.peering_network.name
  import_custom_routes = true
  export_custom_routes = true
}
# [END cloud_sql_mysql_instance_private_ip_routes]

# [START cloud_sql_mysql_instance_private_ip_dns]

## Uncomment this block after adding a valid DNS suffix

# resource "google_service_networking_peered_dns_domain" "default" {
#   name       = "example-com"
#   network    = google_compute_network.peering_network.name
#   dns_suffix = "example.com."
#   service    = "servicenetworking.googleapis.com"
# }

# [END cloud_sql_mysql_instance_private_ip_dns]

# [END cloud_sql_mysql_instance_private_ip]

