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

# [START cloud_sql_sqlserver_instance_ha]
resource "google_sql_database_instance" "default" {
  name             = "sqlserver-instance-ha"
  region           = "us-central1"
  database_version = "SQLSERVER_2019_STANDARD"
  root_password    = "INSERT-PASSWORD-HERE"
  settings {
    tier              = "db-custom-2-7680"
    availability_type = "REGIONAL"
    backup_configuration {
      enabled    = true
      start_time = "20:55"
    }
  }
}
# [END cloud_sql_sqlserver_instance_ha]
