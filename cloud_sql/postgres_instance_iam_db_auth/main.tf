/**
 * Copyright 2024 Google LLC
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

# [START cloud_sql_postgres_instance_iam_db_auth]
# [START cloud_sql_postgres_instance_iam_db_auth_create_instance]
# [START cloud_sql_postgres_instance_iam_db_auth_add_users]
resource "google_sql_database_instance" "default" {
  name             = "postgres-db-auth-instance-name-test"
  region           = "us-west4"
  database_version = "POSTGRES_14"
  settings {
    tier = "db-custom-2-7680"
    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
  }
}
# [END cloud_sql_postgres_instance_iam_db_auth_create_instance]

# Specify the email address of the IAM user to add to the instance
# This resource does not create a new IAM user account; this account must
# already exist

resource "google_sql_user" "iam_user" {
  name     = "test-user@example.com"
  instance = google_sql_database_instance.default.name
  type     = "CLOUD_IAM_USER"
}

# Specify the email address of the IAM service account to add to the instance
# This resource does not create a new IAM service account; this service account
# must already exist

# Create a new IAM service account

resource "google_service_account" "default" {
  account_id   = "cloud-sql-postgres-sa"
  display_name = "Cloud SQL for Postgres Service Account"
}

resource "google_sql_user" "iam_service_account_user" {
  # Note: for PostgreSQL only, Google Cloud requires that you omit the
  # ".gserviceaccount.com" suffix
  # from the service account email due to length limits on database usernames.
  name     = trimsuffix(google_service_account.default.email, ".gserviceaccount.com")
  instance = google_sql_database_instance.default.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}
# [END cloud_sql_postgres_instance_iam_db_auth_add_users]

# [START cloud_sql_postgres_instance_iam_db_grant_roles]
data "google_project" "project" {
}

resource "google_project_iam_binding" "cloud_sql_user" {
  project = data.google_project.project.project_id
  role    = "roles/cloudsql.instanceUser"
  members = [
    "user:test-user@example.com",
    "serviceAccount:${google_service_account.default.email}"
  ]
}

resource "google_project_iam_binding" "cloud_sql_client" {
  project = data.google_project.project.project_id
  role    = "roles/cloudsql.client"
  members = [
    "user:test-user@example.com",
    "serviceAccount:${google_service_account.default.email}"
  ]
}
# [END cloud_sql_postgres_instance_iam_db_grant_roles]
# [END cloud_sql_postgres_instance_iam_db_auth]
