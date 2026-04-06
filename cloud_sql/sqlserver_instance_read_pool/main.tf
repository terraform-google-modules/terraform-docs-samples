/**
 * Copyright 2026 Google LLC
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

# [START cloud_sql_sqlserver_read_pool]

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

resource "google_sql_database_instance" "primary" {
  name             = "sqlserver-primary"
  database_version = "SQLSERVER_2022_ENTERPRISE"
  region           = "europe-west4"
  root_password    = "INSERT-PASSWORD-HERE"

  depends_on = [google_service_networking_connection.default]

  instance_type = "CLOUD_SQL_INSTANCE"

  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"

    backup_configuration {
      enabled = true
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.peering_network.id
    }
  }
}

resource "google_sql_database_instance" "replica" {
  name             = "sqlserver-replica"
  database_version = "SQLSERVER_2022_ENTERPRISE"
  region           = "europe-west4"

  master_instance_name = google_sql_database_instance.primary.name
  instance_type        = "READ_POOL_INSTANCE"
  node_count           = 2

  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"


    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.peering_network.id
    }
  }
}

# [END cloud_sql_sqlserver_read_pool]
