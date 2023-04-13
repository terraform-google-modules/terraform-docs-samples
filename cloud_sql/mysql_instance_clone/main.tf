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

# [START cloud_sql_mysql_instance_source]
resource "google_sql_database_instance" "source" {
  name             = "mysql-instance-source-name"
  region           = "us-central1"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-n1-standard-2"
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by 
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}
# [END cloud_sql_mysql_instance_source]

# [START cloud_sql_mysql_instance_clone]
resource "google_sql_database_instance" "clone" {
  name             = "mysql-instance-clone-name"
  region           = "us-central1"
  database_version = "MYSQL_8_0"
  clone {
    source_instance_name = google_sql_database_instance.source.id
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by 
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}
# [END cloud_sql_mysql_instance_clone]
