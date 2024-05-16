/**
 * Copyright 2024 Google LLC
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

data "google_project" "default" {
}

# [START application_integration_edit_region]
resource "random_id" "default" {
  byte_length = 8
}

resource "google_kms_key_ring" "default" {
  name     = "${random_id.default.hex}-example-keyring"
  location = "us-east1"
}

resource "google_kms_crypto_key" "default" {
  name            = "crypto-key-example"
  key_ring        = google_kms_key_ring.default.id
  rotation_period = "7776000s"
}

resource "google_kms_crypto_key_version" "default" {
  crypto_key = google_kms_crypto_key.default.id
}

resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_integrations_client" "example" {
  location                   = "us-east1"
  create_sample_integrations = true
  run_as_service_account     = google_service_account.default.email
  cloud_kms_config {
    kms_location   = "us-east1"
    kms_ring       = google_kms_key_ring.default.id
    key            = google_kms_crypto_key.default.id
    key_version    = google_kms_crypto_key_version.default.id
    kms_project_id = data.google_project.default.project_id
  }
}
# [END application_integration_edit_region]
