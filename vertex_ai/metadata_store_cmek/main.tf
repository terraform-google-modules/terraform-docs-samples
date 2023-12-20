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


# [START aiplatform_create_metadata_store_cmek]
resource "google_vertex_ai_metadata_store" "default" {
  name        = "${random_id.default.hex}-example-store"
  description = "Example metadata store"
  provider    = google-beta
  region      = "us-central1"
  encryption_spec {
    kms_key_name = google_kms_crypto_key.default.id
  }

  depends_on = [google_project_iam_member.service_account_access]
}

resource "random_id" "default" {
  byte_length = 8
}

resource "google_kms_key_ring" "default" {
  name     = "${random_id.default.hex}-example-keyring"
  location = "us-central1"
}

resource "google_kms_crypto_key" "default" {
  name     = "example-key"
  key_ring = google_kms_key_ring.default.id
}

data "google_project" "default" {
}

# Enable the service account to encrypt/decrypt Cloud KMS keys
resource "google_project_iam_member" "default" {
  project = data.google_project.default.project_id
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:service-${data.google_project.default.number}@gcp-sa-aiplatform.iam.gserviceaccount.com"
}
# [END aiplatform_create_metadata_store_cmek]
