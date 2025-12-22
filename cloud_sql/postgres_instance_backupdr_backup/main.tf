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

# [START cloud_sql_mysql_instance_backupdr_backup_setup]
data "google_backup_dr_backup" "sql_backups" {
  project         = "VAULT-PROJECT-ID"
  location        = "us-central1"
  backup_vault_id = "BACKUP-VAULT-ID"
  data_source_id  = "DATA-SOURCE-ID"
}
# [END cloud_sql_mysql_instance_backupdr_backup_setup]\

# [START cloud_sql_postgres_instance_backupdr_backup]
resource "google_sql_database_instance" "instance" {
  name             = "postgres-instance-backupdr-backup"
  region           = "us-central1"
  database_version = "POSTGRES_17"
  settings {
    tier = "db-f1-micro"
    backup_configuration {
      enabled    = true
      start_time = "20:55"
    }
  }
  backupdr_backup = data.google_backup_dr_backup.sql_backups.backups[0].name
}
# [END cloud_sql_postgres_instance_backupdr_backup]
