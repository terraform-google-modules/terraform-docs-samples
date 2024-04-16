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
data "google_project" "test_project" {
}

resource "google_kms_key_ring" "keyring" {
  name     = "my-keyring"
  location = "us-central1"
}

resource "google_kms_crypto_key" "cryptokey" {
  name            = "crypto-key-example"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "7776000s"
  depends_on      = [google_kms_key_ring.keyring]
}
# [START applicationintegration_edit_region]
resource "google_kms_crypto_key_version" "test_key" {
  crypto_key = google_kms_crypto_key.cryptokey.id
  depends_on = [google_kms_crypto_key.cryptokey]
}

resource "google_integrations_client" "example" {
  location                = "us-central1"
  create_sample_workflows = true
  provision_gmek          = true
  run_as_service_account  = "radndom-service-account"
  cloud_kms_config {
    kms_location   = "us-central1"
    kms_ring       = google_kms_key_ring.keyring.id
    key            = google_kms_crypto_key.cryptokey.id
    key_version    = google_kms_crypto_key_version.test_key.id
    kms_project_id = data.google_project.test_project.id
  }
  depends_on = [google_kms_crypto_key_version.test_key]
}
# [END applicationintegration_edit_region]
