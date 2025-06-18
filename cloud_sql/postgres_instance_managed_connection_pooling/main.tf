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

# [START cloud_sql_postgres_instance_managed_connection_pooling_creation]
resource "google_sql_database_instance" "postgres_managed_connection_pooling_creation" {
  name                = "postgres-instance-managed-connection-pooling-creation"
  region              = "us-central1"
  database_version    = "POSTGRES_16"
  deletion_protection = false

  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"
    connection_pool_config {
      connection_pooling_enabled = true
    }
  }
}
# [END cloud_sql_postgres_instance_managed_connection_pooling_creation]

# [START cloud_sql_postgres_instance_managed_connection_pooling_enable]
resource "google_sql_database_instance" "postgres_managed_connection_pooling_enable" {
  name                = "postgres-instance-managed-connection-pooling-enable"
  region              = "us-central1"
  database_version    = "POSTGRES_16"
  deletion_protection = false

  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"
    connection_pool_config {
      connection_pooling_enabled = true # Set to true here
    }
  }
}
# [END cloud_sql_postgres_instance_managed_connection_pooling_enable]

# [START cloud_sql_postgres_instance_managed_connection_pooling_modify]
resource "google_sql_database_instance" "postgres_managed_connection_pooling_modify" {
  name                = "postgres-instance-managed-connection-pooling-modify"
  region              = "us-central1"
  database_version    = "POSTGRES_16"
  deletion_protection = false

  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"
    connection_pool_config {
      connection_pooling_enabled = true
      flags {
        name  = "max_pool_size" # Modify the value of an existing flag
        value = "10"
      }
    }
  }
}
# [END cloud_sql_postgres_instance_managed_connection_pooling_modify]

# [START cloud_sql_postgres_instance_managed_connection_pooling_disable]
resource "google_sql_database_instance" "postgres_managed_connection_pooling_disable" {
  name                = "postgres-instance-managed-connection-pooling-disable"
  region              = "us-central1"
  database_version    = "POSTGRES_16"
  deletion_protection = false

  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"
    connection_pool_config {
      # Set to false to disable Managed Connection Pooling. You can also remove the block entirely.
      connection_pooling_enabled = false
    }
  }
}
# [END cloud_sql_postgres_instance_managed_connection_pooling_disable]
