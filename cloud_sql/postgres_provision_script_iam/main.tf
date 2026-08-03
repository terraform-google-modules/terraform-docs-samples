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
  database_version = "POSTGRES_17"

  settings {
    tier            = "db-perf-optimized-N-2"
    data_api_access = "ALLOW_DATA_API"
    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
  }
  root_password = "changeme"
}

# [END cloud_sql_provision_script_instance]

# [START cloud_sql_provision_script_iam_user]

# Create a database user for your account and grant roles so it has privilege
# to access the database. Choose an IAM type, e.g., "CLOUD_IAM_USER"
# and "CLOUD_IAM_SERVICE_ACCOUNT". If a service account is used and the
# instance is Postgres, please trim the ".gserviceaccount.com" suffix to
# avoid exceeding the username length limit.
resource "google_sql_user" "iam_user" {
  name     = "account-used-to-apply-this-config@example.com"
  instance = google_sql_database_instance.instance.name
  type     = "CLOUD_IAM_USER"

  # Roles granted to the user. To follow the principle of least privilege, you
  # can first use `google_sql_provision_script` to create custom database role(s)
  # with lesser privileges and then assign them to this user in place of
  # `cloudsqlsuperuser`.
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

resource "google_sql_provision_script" "table" {
  # You can inline the script or import from a file like
  # `script  = file("${path.module}/script.sql")`
  # When modified, the whole script will be executed again. It's recommended to
  # make the script idempotent with patterns like `create if not exists ...` or
  # `if not exists (select ...) then ... end if`. If it's not possible to make a
  # statement idempotent, you can run it once and then remove it from the script.
  script  = "CREATE TABLE IF NOT EXISTS table1 ( col VARCHAR(16) NOT NULL );"

  instance = google_sql_database_instance.instance.name
  database = google_sql_database.database.name
  description = "sql script to create tables"

  # The identity account used to apply your Terraform config must exist as an
  # IAM account in the instance. Terraform connects to the instance via IAM
  # database authentication to execute the script.
  depends_on = [google_sql_user.iam_user]
}

# [END cloud_sql_provision_script_script]
