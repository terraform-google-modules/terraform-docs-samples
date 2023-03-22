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

# [START cloud_sql_postgres_instance_source]
resource "google_sql_database_instance" "source" {
  name             = "postgres-instance-source-name"
  region           = "us-central1"
  database_version = "POSTGRES_12"
  settings {
    tier = "db-n1-standard-2"
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_postgres_instance_source]

# [START cloud_sql_postgres_instance_clone]
resource "google_sql_database_instance" "clone" {
  name             = "postgres-instance-clone-name"
  region           = "us-central1"
  database_version = "POSTGRES_12"
  clone {
    source_instance_name = google_sql_database_instance.source.id
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_postgres_instance_clone]
