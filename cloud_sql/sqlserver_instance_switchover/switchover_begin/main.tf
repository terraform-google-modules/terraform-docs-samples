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

# [START cloud_sql_sqlserver_instance_switchover_begin]
resource "google_sql_database_instance" "original-primary" {
  name             = "sqlserver-primary-instance-name"
  region           = "us-east1"
  database_version = "SQLSERVER_2022_ENTERPRISE"
  instance_type    = "CLOUD_SQL_INSTANCE"
  root_password    = "INSERT-PASSWORD-HERE"
  replica_names    = ["sqlserver-replica-instance-name"]
  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"
    backup_configuration {
      enabled = "true"
    }
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}

resource "google_sql_database_instance" "dr_replica" {
  name = "sqlserver-replica-instance-name"
  # Remove or comment out the master_instance_name
  # master_instance_name = google_sql_database_instance.original-primary.name
  region           = "us-west2"
  database_version = "SQLSERVER_2022_ENTERPRISE"
  # Change the instance type from "READ_REPLICA_INSTANCE" to "CLOUD_SQL_INSTANCE".
  instance_type = "CLOUD_SQL_INSTANCE"
  root_password = "INSERT-PASSWORD-HERE"
  # Add the original primary to the replica_names list
  replica_names = ["sqlserver-primary-instance-name"]
  # Remove or comment out the replica_configuration section
  # replica_configuration {
  #  cascadable_replica = true
  # }

  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}
# [END cloud_sql_sqlserver_instance_switchover_begin]
