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

data "google_project" "project" {
}

# [START vpc_postgres_instance_consumer_network]
resource "google_compute_network" "consumer_network" {
  name                    = "consumer-network"
  auto_create_subnetworks = "true"
}
# [END vpc_postgres_instance_consumer_network]

# [START cloud_sql_postgres_instance_psc_sa]
resource "google_sql_database_instance" "default" {
  name             = "postgres-instance"
  region           = "us-central1"
  database_version = "POSTGRES_14"
  settings {
    tier              = "db-custom-2-7680"
    availability_type = "REGIONAL"
    backup_configuration {
      enabled = true
    }
    ip_configuration {
      psc_config {
        psc_enabled               = true
        allowed_consumer_projects = []
        psc_auto_connections {
          consumer_network            = google_compute_network.consumer_network.id
          consumer_service_project_id = data.google_project.project.project_id
        }
      }
      ipv4_enabled = false
    }
  }
}
# [END cloud_sql_postgres_instance_psc_sa]
