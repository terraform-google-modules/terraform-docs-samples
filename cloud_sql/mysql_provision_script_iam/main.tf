/**
 * Copyright 2026 Google LLC
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

# [START cloud_sql_provision_script_instance]

resource "random_password" "pwd" {
  length = 16
}

resource "google_sql_database_instance" "instance" {
  name             = "my-instance"
  database_version = "MYSQL_8_4"
  region           = "us-central1"

  settings {
    tier            = "db-perf-optimized-N-2"
    data_api_access = "ALLOW_DATA_API"
    database_flags {
      name  = "cloudsql_iam_authentication"
      value = "on"
    }
  }
  root_password = random_password.pwd.result
}

# [END cloud_sql_provision_script_instance]

# [START cloud_sql_provision_script_iam_user]

resource "google_sql_user" "iam_user" {
  name     = "account-used-to-apply-this-config@example.com"
  instance = google_sql_database_instance.instance.name
  type     = "CLOUD_IAM_USER"
  database_roles = ["cloudsqlsuperuser"]
}

# [END cloud_sql_provision_script_iam_user]

# [START cloud_sql_provision_script_database]

resource "google_sql_database" "database" {
  name     = "my-database"
  instance = google_sql_database_instance.instance.name
}

# [END cloud_sql_provision_script_database]

# [START cloud_sql_provision_script_script]

resource "google_sql_provision_script" "script" {
  script      = file("${path.module}/script.sql")
  description = "sql script to create DBs and tables"
  instance    = google_sql_database_instance.instance.name
  database    = google_sql_database.database.name
  depends_on  = [google_sql_user.iam_user]
}

# [END cloud_sql_provision_script_script]
