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

# [START cloud_sql_postgres_instance_require_ssl]
resource "google_sql_database_instance" "postgres_instance" {
  name             = "postgres-instance"
  region           = "asia-northeast1"
  database_version = "POSTGRES_14"
  settings {
    tier = "db-custom-2-7680"
    ip_configuration {
      # The following SSL enforcement options only allow connections encrypted with SSL/TLS and with
      # valid client certificates. Please check the API reference for other SSL enforcement options:
      # https://cloud.google.com/sql/docs/postgres/admin-api/rest/v1beta4/instances#ipconfiguration
      require_ssl = "true"
      ssl_mode    = "TRUSTED_CLIENT_CERTIFICATE_REQUIRED"
    }
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}
# [END cloud_sql_postgres_instance_require_ssl]

# [START cloud_sql_postgres_instance_ssl_cert]
resource "google_sql_ssl_cert" "postgres_client_cert" {
  common_name = "postgres_common_name"
  instance    = google_sql_database_instance.postgres_instance.name
}
# [END cloud_sql_postgres_instance_ssl_cert]
