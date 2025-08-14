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

# [START cloud_sql_sqlserver_instance_switchover_finish]
resource "google_sql_database_instance" "original-primary" {
  name = "sqlserver-primary-instance-name"
  # Set master_instance_name to the new primary instance, the original DR replica.
  master_instance_name = "sqlserver-replica-instance-name"
  region               = "us-east1"
  database_version     = "SQLSERVER_2022_ENTERPRISE"
  # Change the instance type from "CLOUD_SQL_INSTANCE" to "READ_REPLICA_INSTANCE".
  instance_type = "READ_REPLICA_INSTANCE"
  root_password = "INSERT-PASSWORD-HERE"
  # Remove  values from the replica_names field, but don't remove the field itself.
  replica_names = []
  # Add replica_configuration section and set cascadable_replica to true.
  replica_configuration {
    cascadable_replica = true
  }
  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"
    backup_configuration {
      enabled = "true"
    }
  }
}

resource "google_sql_database_instance" "dr_replica" {
  name             = "sqlserver-replica-instance-name"
  region           = "us-west2"
  database_version = "SQLSERVER_2022_ENTERPRISE"
  # Change the instance type from "READ_REPLICA_INSTANCE" to "CLOUD_SQL_INSTANCE".
  instance_type = "CLOUD_SQL_INSTANCE"
  root_password = "INSERT-PASSWORD-HERE"
  # Add the original primary to the replica_names list
  replica_names = ["sqlserver-primary-instance-name"]
  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"
  }
}
# [END cloud_sql_sqlserver_instance_switchover_finish]
