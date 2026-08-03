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

resource "google_sql_database_instance" "instance" {
  name             = "my-instance"
  database_version = "MYSQL_8_4"

  settings {
    tier            = "db-perf-optimized-N-2"
    data_api_access = "ALLOW_DATA_API"
    database_flags {
      name  = "cloudsql_iam_authentication"
      value = "on"
    }
  }
  root_password = "changeme"
}

# [END cloud_sql_provision_script_instance]

# [START cloud_sql_provision_script_builtin_user]

resource "google_sql_user" "built_in_user" {
  name     = "tf-user"
  host     = "%"
  instance = google_sql_database_instance.instance.name
  password = "changeme"
  type     = "BUILT_IN"
}

# [END cloud_sql_provision_script_builtin_user]

# [START cloud_sql_provision_script_secret]

# Create a regional secret. Global secrets are not supported even if
# located in one region only.
resource "google_secret_manager_regional_secret" "secret" {
  secret_id = "db-password"

  # Use the same region as the Cloud SQL instance.
  location = "us-central1"
}

# [END cloud_sql_provision_script_secret]

# [START cloud_sql_provision_script_secret_version]

resource "google_secret_manager_regional_secret_version" "secret_version" {
  secret = google_secret_manager_regional_secret.secret.id
  secret_data = "changeme"
}

# [END cloud_sql_provision_script_secret_version]

# [START cloud_sql_provision_script_script]

resource "google_sql_provision_script" "script" {
  # You can inline the script or import from a file like
  # `script  = file("${path.module}/script.sql")`
  # When modified, the whole script will be executed again. It's recommended to
  # make the script idempotent with patterns like `create if not exists ...` or
  # `if not exists (select ...) then ... end if`. If it's not possible to make a
  # statement idempotent, you can run it once and then remove it from the script.
  script  = file("${path.module}/script.sql")

  description = "sql script to create DBs and tables"
  instance = google_sql_database_instance.instance.name

  # Some of your queries may require a database. You can create and use a
  # database inside the script, or explicitly reference a google_sql_database
  # like `database = google_sql_database.database.name`.

  user = google_sql_user.built_in_user.name

  # The location should be the same as the Cloud SQL instance's location.
  password_secret_version = "projects/my-project/locations/us-central1/secrets/db-password/versions/latest"

  # The built-in database user and password secret version must be created
  # first. Cloud SQL will retrieve password from Secret Manager
  # and connect to this user account to execute your script.
  depends_on = [
    google_sql_user.built_in_user,
    google_secret_manager_regional_secret_version.secret_version
  ]
}

# [END cloud_sql_provision_script_script]
