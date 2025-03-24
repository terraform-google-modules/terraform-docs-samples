/**
 * Copyright 2025 Google LLC
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

# [START eventarc_terraform_cmek_apis]
# Enable Cloud KMS API
resource "google_project_service" "cloudkms" {
  service            = "cloudkms.googleapis.com"
  disable_on_destroy = false
}

# Enable Eventarc API
resource "google_project_service" "eventarc" {
  service            = "eventarc.googleapis.com"
  disable_on_destroy = false
}
# [END eventarc_terraform_cmek_apis]

# Used to retrieve project information later
data "google_project" "default" {
}

# [START eventarc_terraform_service_agent]
resource "google_project_service_identity" "eventarc_sa" {
  provider = google-beta
  project  = data.google_project.default.project_id
  service  = "eventarc.googleapis.com"
}
# [END eventarc_terraform_service_agent]

# [START eventarc_terraform_cmek_key]
resource "random_id" "default" {
  byte_length = 8
}

# Create a Cloud KMS key ring
resource "google_kms_key_ring" "default" {
  name     = "${random_id.default.hex}-example-keyring"
  location = "us-central1"
}

# Create a Cloud KMS key
resource "google_kms_crypto_key" "default" {
  name            = "example-key"
  key_ring        = google_kms_key_ring.default.id
  rotation_period = "7776000s"
}
# [END eventarc_terraform_cmek_key]

# [START eventarc_terraform_cmek_role]
# Grant service account access to Cloud KMS key
resource "google_kms_crypto_key_iam_member" "default" {
  crypto_key_id = google_kms_crypto_key.default.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = google_project_service_identity.eventarc_sa.member
}
# [END eventarc_terraform_cmek_role]

# [START eventarc_terraform_cmek_google_channel]
# Specify a CMEK key for the `GoogleChannelConfig` resource
resource "google_eventarc_google_channel_config" "default" {
  location        = "us-central1"
  name            = "googleChannelConfig"
  crypto_key_name = google_kms_crypto_key.default.id
  depends_on      = [google_kms_crypto_key_iam_member.default]
}
# [END eventarc_terraform_cmek_google_channel]
