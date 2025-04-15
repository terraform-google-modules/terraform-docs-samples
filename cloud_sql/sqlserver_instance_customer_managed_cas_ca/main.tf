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

# [START cloud_sql_sqlserver_instance_require_ssl]
resource "google_sql_database_instance" "sqlserver_instance" {
  name             = "sqlserver-instance"
  region           = "asia-northeast1"
  database_version = "SQLSERVER_2019_STANDARD"
  root_password    = "INSERT-PASSWORD-HERE"
  settings {
    tier = "db-custom-2-7680"
    ip_configuration {
      # The following server CA mode lets the instance use customer-managed CAS CA to issue server certificates.
      # https://cloud.google.com/sql/docs/sqlserver/admin-api/rest/v1beta4/instances#ipconfiguration
      server_ca_mode = "CUSTOMER_MANAGED_CAS_CA"
      # This is the name of the customer-owned CAS CA pool.
      server_ca_pool = "projects/my-project/locations/asia-northeast1/caPools/my-pool"
    }
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}
# [END cloud_sql_sqlserver_instance_require_ssl]
