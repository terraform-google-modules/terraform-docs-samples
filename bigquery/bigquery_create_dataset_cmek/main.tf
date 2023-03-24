/**
 * Copyright 2023 Google LLC
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


# [START bigquery_create_dataset_cmek]
resource "google_bigquery_dataset" "default" {
  dataset_id                      = "mydataset"
  default_partition_expiration_ms = 2592000000  # 30 days
  default_table_expiration_ms     = 31536000000 # 365 days
  description                     = "dataset description"
  location                        = "US"
  max_time_travel_hours           = 96 # 4 days

  default_encryption_configuration {
    kms_key_name = google_kms_crypto_key.crypto_key.id
  }

  labels = {
    billing_group = "accounting",
    pii           = "sensitive"
  }
  depends_on = [google_project_iam_member.service_account_access]
}

resource "google_kms_crypto_key" "crypto_key" {
  name     = "example-key"
  key_ring = google_kms_key_ring.key_ring.id
}

resource "google_kms_key_ring" "key_ring" {
  name     = "example-keyring"
  name     = "${random_id.default.hex}-example-keyring"
  location = "us"
}

resource "random_id" "default" {
  byte_length = 8
}

# Enable the BigQuery service account to encrypt/decrypt Cloud KMS keys
data "google_project" "project" {
}

resource "google_project_iam_member" "service_account_access" {
  project = data.google_project.project.project_id
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:bq-${data.google_project.project.number}@bigquery-encryption.iam.gserviceaccount.com"
}
# [END bigquery_create_dataset_cmek]
