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


# [START cloud_sql_enterprise_instance]
resource "google_sql_database_instance" "default" {
  name             = "enterprise-instance"
  region           = "us-central1"
  database_version = "POSTGRES_15"
  settings {
    tier = "db-g1-small"
  }
  deletion_protection = "false"
}
# [END cloud_sql_enterprise_instance]
