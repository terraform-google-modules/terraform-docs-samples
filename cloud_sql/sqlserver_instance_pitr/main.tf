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

# [START cloud_sql_sqlserver_instance_enterprise_plus_pitr]
# Creates a SQL SERVER Enterprise Plus edition instance. Unless specified otherwise, PITR is enabled by default.
resource "google_sql_database_instance" "enterprise_plus" {
  name             = "sqlserver-enterprise-plus-instance-pitr"
  region           = "asia-northeast1"
  database_version = "SQLSERVER_2019_ENTERPRISE"
  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"
    backup_configuration {
      enabled = true
    }
  }
  # Setting the `deletion_protection` flag to true ensures you can't accidentally delete the instance
  # using Terraform. Setting the `deletion_protection_enabled` flag to true protects the instance at the
  # Google Cloud level.
  deletion_protection = false
}
# [END cloud_sql_sqlserver_instance_enterprise_plus_pitr]

# [START cloud_sql_sqlserver_instance_enterprise_pitr]
# Creates a SQL SERVER Enterprise edition instance with PITR enabled. Unless specified otherwise,
# PITR is disabled by default.
resource "google_sql_database_instance" "enterprise" {
  name             = "sqlserver-enterprise-instance-pitr"
  region           = "asia-northeast1"
  database_version = "SQLSERVER_2019_ENTERPRISE"
  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE"
    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
    }
  }
  # Setting the `deletion_protection` flag to true ensures you can't accidentally delete the instance
  # using Terraform. Setting the `deletion_protection_enabled` flag to true protects the instance at the
  # Google Cloud level.
  deletion_protection = false
}
# [END cloud_sql_sqlserver_instance_enterprise_pitr]
