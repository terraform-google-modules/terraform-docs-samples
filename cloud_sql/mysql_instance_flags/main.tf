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

# [START cloud_sql_mysql_instance_flags]
resource "google_sql_database_instance" "instance" {
  database_version = "MYSQL_8_0"
  name             = "mysql-instance"
  region           = "us-central1"
  settings {
    database_flags {
      name  = "general_log"
      value = "on"
    }
    database_flags {
      name  = "skip_show_database"
      value = "on"
    }
    database_flags {
      name  = "wait_timeout"
      value = "200000"
    }
    disk_type = "PD_SSD"
    tier      = "db-n1-standard-2"
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_mysql_instance_flags]
