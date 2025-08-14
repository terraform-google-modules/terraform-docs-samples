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

# [START cloud_sql_postgres_read_pool]

resource "google_sql_database_instance" "primary" {
  name             = "postgres-primary"
  database_version = "POSTGRES_17"
  region           = "europe-west4"

  instance_type = "CLOUD_SQL_INSTANCE"

  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"

    backup_configuration {
      enabled = true
    }

    ip_configuration {
      ipv4_enabled = true
    }
  }
}

resource "google_sql_database_instance" "replica" {
  name             = "postgres-replica"
  database_version = "POSTGRES_17"
  region           = "europe-west4"

  master_instance_name = google_sql_database_instance.primary.name
  instance_type        = "READ_POOL_INSTANCE"
  node_count           = 2

  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"

    ip_configuration {
      ipv4_enabled = true
    }
  }
}

# [END cloud_sql_postgres_read_pool]
