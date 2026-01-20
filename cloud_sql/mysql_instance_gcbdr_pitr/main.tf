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

# [START cloud_sql_mysql_instance_gcbdr_pitr]

data "google_project" "project" {}

resource "google_sql_database_instance" "default" {
  name             = "mysql-instance-backup-pitr"
  region           = "us-central1"
  database_version = "MYSQL_8_0"
  root_password    = "INSERT-PASSWORD-HERE"
  settings {
    tier = "db-custom-2-7680"
    backup_configuration {
      enabled    = true
      start_time = "20:55"
    }
  }
  point_in_time_restore_context {
    datasource      = google_backup_dr_backup_plan_association.default_association.data_source
    point_in_time   = "2025-12-22T08:51:50Z" # Replace with the point in time to restore to.
    target_instance = "${data.google_project.project.project_id}:mysql-instance-backup-pitr"
  }
}
# [END cloud_sql_mysql_instance_gcbdr_pitr]
