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

# [START cloud_sql_sqlserver_instance_pitr]
resource "google_sql_database_instance" "default" {
  name             = "sqlserver-instance-pitr"
  region           = "asia-northeast1"
  database_version = "SQLSERVER_2019_ENTERPRISE"
  root_password    = "INSERT-PASSWORD-HERE"
  settings {
    tier = "db-custom-4-26624"
    backup_configuration {
      enabled                        = true
      start_time                     = "20:55"
      transaction_log_retention_days = "3"
    }
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}
# [END cloud_sql_sqlserver_instance_pitr]
