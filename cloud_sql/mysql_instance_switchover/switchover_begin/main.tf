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

# [START cloud_sql_mysql_instance_switchover_begin]
#
# This sample provides the first part of the switchover operation and turns the DR replica
# into the new primary instance.
data "google_project" "default" {
}

resource "google_sql_database_instance" "original-primary" {
  name             = "mysql-original-primary-instance"
  region           = "us-east1"
  database_version = "MYSQL_8_0"
  instance_type    = "CLOUD_SQL_INSTANCE"

  replication_cluster {
    failover_dr_replica_name = "${data.google_project.default.project_id}:mysql-dr-replica-instance"
  }

  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"
    backup_configuration {
      enabled            = true
      binary_log_enabled = true
    }
  }
  # Set `deletion_protection` to true to ensure that one can't accidentally
  # delete this instance by use of Terraform whereas
  # `deletion_protection_enabled` flag protects this instance at the Google Cloud level.
  deletion_protection = false
  # Optional. Add more settings.
}

resource "google_sql_database_instance" "dr-replica" {
  name             = "mysql-dr-replica-instance"
  region           = "us-west2"
  database_version = "MYSQL_8_0"
  # Change the instance type from "READ_REPLICA_INSTANCE" to "CLOUD_SQL_INSTANCE".
  instance_type = "CLOUD_SQL_INSTANCE"
  # Remove or comment out the master_instance_name from the DR replica.
  # master_instance_name = google_sql_database_instance.original-primary.name
  # Add the original primary instance to a list of replicas for the new primary.
  replica_names = [google_sql_database_instance.original-primary.name]

  # Designate the original primary instance as the DR replica of the new primary instance.
  # The format for setting the DR replica is `project-id:dr-replica-name`.
  replication_cluster {
    failover_dr_replica_name = "${data.google_project.default.project_id}:${google_sql_database_instance.original-primary.name}"
  }

  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"
    backup_configuration {
      # Add a backup configuration section to enable automated backups and binary logging for the new primary instance.
      enabled            = true
      binary_log_enabled = true
    }
  }
  # Set `deletion_protection` to true to ensure that one can't accidentally
  # delete this instance by use of Terraform whereas
  # `deletion_protection_enabled` flag protects this instance at the Google Cloud level.
  deletion_protection = false
  # Optional. Add more settings.
}

# [END cloud_sql_mysql_instance_switchover_invoke]