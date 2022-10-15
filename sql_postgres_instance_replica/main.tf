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

# [START cloud_sql_postgres_instance_primary]
resource "google_sql_database_instance" "primary" {
  name             = "postgres-primary-instance-name"
  region           = "europe-west4"
  database_version = "POSTGRES_14"
  settings {
    tier = "db-custom-2-7680"
    backup_configuration {
      enabled = "true"
    }
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_postgres_instance_primary]

# [START cloud_sql_postgres_instance_replica]
resource "google_sql_database_instance" "read_replica" {
  name                 = "postgres-replica-instance-name"
  master_instance_name = google_sql_database_instance.primary.name
  region               = "europe-west4"
  database_version     = "POSTGRES_14"

  replica_configuration {
    failover_target = false
  }

  settings {
    tier              = "db-custom-2-7680"
    availability_type = "ZONAL"
    disk_size         = "100"
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_postgres_instance_replica]
