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

# [START cloud_sql_instance_service_identity]
resource "google_project_service_identity" "gcp_sa_cloud_sql" {
  provider = google-beta
  service  = "sqladmin.googleapis.com"
}
# [END cloud_sql_instance_service_identity]

# [START cloud_sql_instance_keyring]
resource "google_kms_key_ring" "keyring" {
  provider = google-beta
  name     = "keyring-name"
  location = "us-central1"
}
# [END cloud_sql_instance_keyring]

# [START cloud_sql_instance_key]
resource "google_kms_crypto_key" "key" {
  provider = google-beta
  name     = "crypto-key-name"
  key_ring = google_kms_key_ring.keyring.id
  purpose  = "ENCRYPT_DECRYPT"
}
# [END cloud_sql_instance_key]

# [START cloud_sql_instance_crypto_key]
resource "google_kms_crypto_key_iam_binding" "crypto_key" {
  provider      = google-beta
  crypto_key_id = google_kms_crypto_key.key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_project_service_identity.gcp_sa_cloud_sql.email}",
  ]
}
# [END cloud_sql_instance_crypto_key]

# [START cloud_sql_mysql_instance_cmek]
resource "google_sql_database_instance" "mysql_instance_with_cmek" {
  name                = "mysql-instance-cmek"
  provider            = google-beta
  region              = "us-central1"
  database_version    = "MYSQL_8_0"
  encryption_key_name = google_kms_crypto_key.key.id
  settings {
    tier = "db-n1-standard-2"
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}
# [END cloud_sql_mysql_instance_cmek]

# [START cloud_sql_postgres_instance_cmek]
resource "google_sql_database_instance" "postgres_instance_with_cmek" {
  name                = "postgres-instance-cmek"
  provider            = google-beta
  region              = "us-central1"
  database_version    = "POSTGRES_14"
  encryption_key_name = google_kms_crypto_key.key.id
  settings {
    tier = "db-custom-2-7680"
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}
# [END cloud_sql_postgres_instance_cmek]

# [START cloud_sql_sqlserver_instance_cmek]
resource "google_sql_database_instance" "default" {
  name                = "sqlserver-instance-cmek"
  provider            = google-beta
  region              = "us-central1"
  database_version    = "SQLSERVER_2019_STANDARD"
  root_password       = "INSERT-PASSWORD-HERE "
  encryption_key_name = google_kms_crypto_key.key.id
  settings {
    tier = "db-custom-2-7680"
  }
}
# [END cloud_sql_sqlserver_instance_cmek]
