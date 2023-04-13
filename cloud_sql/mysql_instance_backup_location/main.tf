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

# [START cloud_sql_mysql_instance_backup_location]
resource "google_sql_database_instance" "default" {
  name             = "mysql-instance-with-backup-location"
  region           = "asia-northeast1"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-f1-micro"
    backup_configuration {
      enabled  = true
      location = "asia-northeast1"
    }
  }
  deletion_protection = false # set `deletion_protection_enabled` flag to true to enable deletion protection of an instance at the GCP level. Enabling this protection will guard against accidental deletion across all surfaces (API, gcloud, Cloud Console and Terraform) by enabling the GCP Cloud SQL instance deletion protection. On the other hand, `deletion_protection` flag prevents destroy of the resource only when the deletion is attempted in terraform.
}
# [END cloud_sql_mysql_instance_backup_location]
