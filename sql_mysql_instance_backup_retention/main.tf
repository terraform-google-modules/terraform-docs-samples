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

# [START cloud_sql_mysql_instance_backup_retention]
resource "google_sql_database_instance" "default" {
  name             = "mysql-instance-backup-retention"
  region           = "asia-northeast1"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-f1-micro"
    backup_configuration {
      enabled = true
      backup_retention_settings {
        retained_backups = 365
        retention_unit   = "COUNT"
      }
    }
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_mysql_instance_backup_retention]
