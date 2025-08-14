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

# [START cloud_sql_sqlserver_instance_create_dr_replica]
resource "google_sql_database_instance" "original-primary" {
  name   = "sqlserver-primary-instance-name"
  region = "us-east1"
  # Specify a database version that supports Cloud SQL Enterprise Plus edition.
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
}

resource "google_sql_database_instance" "dr_replica" {
  name = "sqlserver-replica-instance-name"
  # Specify the original primary instance as the master instance.
  master_instance_name = google_sql_database_instance.original-primary.name
  # DR replica must be in a different region than the region of the primary instance.
  region = "us-west2"
  # DR replica must be the same database version as the primary instance.
  database_version = "SQLSERVER_2022_ENTERPRISE"
  instance_type    = "READ_REPLICA_INSTANCE"
  root_password    = "INSERT-PASSWORD-HERE"
  replica_configuration {
    # Make the replica a cascadable replica.
    cascadable_replica = true
  }

  settings {
    # DR replica must be in the same tier as your primary instance and support Enterprise Plus edition.
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"
  }
}
# [END cloud_sql_sqlserver_instance_create_dr_replica]
