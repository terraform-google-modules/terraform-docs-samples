/**
 * Copyright 2025 Google LLC
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

// Create a Cloud SQL SQL server instance with both Private IP and Private Service Connect enabled.
# [START cloud_sql_sqlserver_instance_psa_psc_parent_tag]

resource "google_compute_network" "peering_network" {
  name                    = "private-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.peering_network.id
}

resource "google_service_networking_connection" "default" {
  network                 = google_compute_network.peering_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# [START cloud_sql_sqlserver_instance_psa_psc_instance]
resource "google_sql_database_instance" "default" {
  name             = "sqlserver-instance"
  region           = "us-central1"
  database_version = "SQLSERVER_2019_STANDARD"
  root_password    = "INSERT-PASSWORD-HERE"

  depends_on = [google_service_networking_connection.default]

  settings {
    tier = "db-custom-2-7680"
    ip_configuration {
      psc_config {
        psc_enabled               = true
        allowed_consumer_projects = [] # Add consumer project IDs here.
      }
      ipv4_enabled    = false
      private_network = google_compute_network.peering_network.id
    }
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}
# [END cloud_sql_sqlserver_instance_psa_psc_instance]

resource "google_compute_network_peering_routes_config" "peering_routes" {
  peering              = google_service_networking_connection.default.peering
  network              = google_compute_network.peering_network.name
  import_custom_routes = true
  export_custom_routes = true
}

resource "google_compute_address" "default" {
  name         = "psc-compute-address-${google_sql_database_instance.default.name}"
  region       = "us-central1"
  address_type = "INTERNAL"
  subnetwork   = "default"      # Replace value with the name of the subnet here.
  address      = "192.168.0.44" # Replace value with the IP address to reserve.
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
}

# [END cloud_sql_sqlserver_instance_psa_psc_parent_tag]

