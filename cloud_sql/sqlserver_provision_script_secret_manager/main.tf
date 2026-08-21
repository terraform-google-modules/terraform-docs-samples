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
  database_version = "SQLSERVER_2025_ENTERPRISE"
  region           = "us-central1"

  settings {
    tier            = "db-perf-optimized-N-2"
    data_api_access = "ALLOW_DATA_API"
  }
  root_password = random_password.pwd.result
}

# [END cloud_sql_provision_script_instance]

# [START cloud_sql_provision_script_secret]

resource "google_secret_manager_regional_secret" "secret" {
  secret_id = "db-password"
  location  = "us-central1"
}

resource "google_secret_manager_regional_secret_version" "secret_version" {
  secret      = google_secret_manager_regional_secret.secret.id
  secret_data = random_password.pwd.result
}

data "google_project" "project" {}

resource "google_project_iam_member" "secret_accessor" {
  project = data.google_project.project.id
  role    = "roles/secretmanager.secretAccessor"
  member  = "user:account-used-to-apply-this-config@example.com"
}

# [END cloud_sql_provision_script_secret]

# [START cloud_sql_provision_script_database]

resource "google_sql_database" "database" {
  name     = "my-database"
  instance = google_sql_database_instance.instance.name
}

# [END cloud_sql_provision_script_database]

# [START cloud_sql_provision_script_script]

resource "google_sql_provision_script" "script" {
  script                  = file("${path.module}/script.sql")
  instance                = google_sql_database_instance.instance.name
  database                = google_sql_database.database.name
  description             = "sql script to create tables, create roles, and grant privileges"
  user                    = 'sqlserver'
  password_secret_version = "projects/${data.google_project.project.id}/locations/us-central1/secrets/db-password/versions/latest"

  depends_on = [
    google_sql_user.built_in_user,
    google_secret_manager_regional_secret_version.secret_version
  ]
}

# [END cloud_sql_provision_script_script]
