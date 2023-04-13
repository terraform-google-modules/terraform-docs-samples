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

# [START cloud_sql_sqlserver_instance_authorized_network]
resource "google_sql_database_instance" "default" {
  name             = "sqlserver-instance-with-authorized-network"
  region           = "us-central1"
  database_version = "SQLSERVER_2019_STANDARD"
  root_password    = "INSERT-PASSWORD-HERE"
  settings {
    tier = "db-custom-2-7680"
    ip_configuration {
      authorized_networks {
        name            = "Network Name"
        value           = "192.0.2.0/24"
        expiration_time = "3021-11-15T16:19:00.094Z"
      }
    }
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by 
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}
# [END cloud_sql_sqlserver_instance_authorized_network]
