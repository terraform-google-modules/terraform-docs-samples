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

# [START cloud_sql_mysql_user_db_role_parent_tag]
# [START cloud_sql_mysql_user_db_role_instance]
resource "google_sql_database_instance" "default" {
  name             = "mysql-user-db-role-test"
  region           = "us-west4"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-f1-micro"
    database_flags {
      name  = "cloudsql_iam_authentication"
      value = "on"
    }
  }
}
# [END cloud_sql_mysql_user_db_role_instance]

# [START cloud_sql_mysql_user_db_role_iam_user]
resource "google_sql_user" "iam_user" {
  name     = "test-user@example.com"
  instance = google_sql_database_instance.default.name
  type     = "CLOUD_IAM_USER"
  # Specify the list of database roles to be granted to the user
  # The database roles must exist in the database.
  database_roles = ["cloudsqlsuperuser"]
}
# [END cloud_sql_mysql_user_db_role_iam_user]
# [START cloud_sql_mysql_user_db_role_built_in_user]
resource "google_sql_user" "builtin_user" {
  name     = "test-user1"
  password = "password"
  instance = google_sql_database_instance.default.name
  # Specify the list of database roles to be granted to the user
  # The database roles must exist in the database.
  database_roles = ["cloudsqlsuperuser"]
}
# [END cloud_sql_mysql_user_db_role_built_in_user]
# [END cloud_sql_mysql_user_db_role_parent_tag]
