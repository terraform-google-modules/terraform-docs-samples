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


# [START cloud_sql_postgres_instance_switchover_dr_replica_create]
resource "google_sql_database_instance" "original-primary" {
  name = "postgres-original-primary-instance"
  # You can specify any region.
  region = "us-east1"
  # Specify a database version that supports Cloud SQL Enterprise Plus edition.
  database_version = "POSTGRES_12"
  instance_type    = "CLOUD_SQL_INSTANCE"

  settings {
    # Specify a tier that supports Cloud SQL Enterprise Plus edition.
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"
    backup_configuration {
      # You must enable automated backups and point-in-time-recovery (PITR).
      enabled                        = true
      point_in_time_recovery_enabled = true
    }
  }
  # Set `deletion_protection` to true to ensure that one can't accidentally
  # delete this instance by use of Terraform whereas
  # `deletion_protection_enabled` flag protects this instance at the Google Cloud level.
  deletion_protection = false
  # Optional. Add more settings.
}

resource "google_sql_database_instance" "dr-replica" {
  name = "postgres-dr-replica-instance"
  # DR replica must be in a different region than the region of the primary instance.
  region = "us-west2"
  # DR replica must be the same database version as the primary instance.
  database_version = "POSTGRES_12"
  instance_type    = "READ_REPLICA_INSTANCE"
  # Specify the primary instance as the master instance.
  master_instance_name = google_sql_database_instance.original-primary.name

  settings {
    # DR replica must be in the same tier as your primary instance and support Enterprise Plus edition.
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"
  }

  # Set `deletion_protection` to true to ensure that one can't accidentally
  # delete this instance by use of Terraform whereas
  # `deletion_protection_enabled` flag protects this instance at the Google Cloud level.
  deletion_protection = false
  # Optional. Add more settings.
}
# [END cloud_sql_postgres_instance_switchover_dr_replica_create]
