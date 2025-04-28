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

# [START cloud_sql_postgres_instance_backup_retention]
resource "google_sql_database_instance" "default" {
  name             = "postgres-instance-backup-retention"
  region           = "us-central1"
  database_version = "POSTGRES_14"
  settings {
    tier = "db-custom-2-7680"
    backup_configuration {
      enabled = true
      backup_retention_settings {
        retained_backups = 365
        retention_unit   = "COUNT"
      }
    }
  }
}
# [END cloud_sql_postgres_instance_backup_retention]
