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

# [START eventarc_advanced_terraform_cmek_apis]
# Enable Compute Engine API
resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

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

# Enable Cloud Pub/Sub API
resource "google_project_service" "pubsub" {
  service            = "pubsub.googleapis.com"
  disable_on_destroy = false
}
# [END eventarc_advanced_terraform_cmek_apis]

# Used to retrieve project information later
data "google_project" "default" {
}

# [START eventarc_advanced_terraform_service_agent]
resource "google_project_service_identity" "eventarc_sa" {
  provider = google-beta
  project  = data.google_project.default.project_id
  service  = "eventarc.googleapis.com"
}
# [END eventarc_advanced_terraform_service_agent]

# [START eventarc_advanced_terraform_cmek_key]
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
# [END eventarc_advanced_terraform_cmek_key]

# [START eventarc_advanced_terraform_cmek_role]
# Grant service account access to Cloud KMS key
resource "google_kms_crypto_key_iam_member" "default" {
  crypto_key_id = google_kms_crypto_key.default.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.eventarc_sa.email}"
}
# [END eventarc_advanced_terraform_cmek_role]

# [START eventarc_advanced_terraform_cmek_bus]
# Enable CMEK for an Eventarc Advanced bus
resource "google_eventarc_message_bus" "default" {
  location        = "us-central1"
  message_bus_id  = "example-bus"
  crypto_key_name = google_kms_crypto_key.default.id
  depends_on      = [google_kms_crypto_key_iam_member.default]
}
# [END eventarc_advanced_terraform_cmek_bus]

# [START eventarc_advanced_terraform_cmek_google_source]
# Enable CMEK for Google API sources
resource "google_eventarc_google_api_source" "default" {
  location             = "us-central1"
  google_api_source_id = "example-google-api-source"
  destination          = google_eventarc_message_bus.default.id
  crypto_key_name      = google_kms_crypto_key.default.id
  depends_on           = [google_kms_crypto_key_iam_member.default]
}
# [END eventarc_advanced_terraform_cmek_google_source]

# [START eventarc_advanced_terraform_cmek_network]
# Create a network
resource "google_compute_network" "default" {
  name                    = "example-network"
  auto_create_subnetworks = false
}
# [END eventarc_advanced_terraform_cmek_network]

# [START eventarc_advanced_terraform_cmek_subnet]
# Create a subnetwork
resource "google_compute_subnetwork" "default" {
  name                     = "example-subnetwork"
  region                   = "us-central1"
  network                  = google_compute_network.default.id
  ip_cidr_range            = "10.8.0.0/24"
  private_ip_google_access = true
}
# [END eventarc_advanced_terraform_cmek_subnet]

# [START eventarc_advanced_terraform_cmek_netattach]
# Create a network attachment
resource "google_compute_network_attachment" "default" {
  name                  = "example-network-attachment"
  region                = "us-central1"
  connection_preference = "ACCEPT_AUTOMATIC"
  subnetworks = [
    google_compute_subnetwork.default.self_link
  ]
}
# [END eventarc_advanced_terraform_cmek_netattach]

# [START eventarc_advanced_terraform_cmek_topic]
# Create a Pub/Sub topic
resource "google_pubsub_topic" "default" {
  name = "example-topic"
}
# [END eventarc_advanced_terraform_cmek_topic]

# [START eventarc_advanced_terraform_cmek_pipeline]
# Enable CMEK for an Eventarc Advanced pipeline
resource "google_eventarc_pipeline" "default" {
  location        = "us-central1"
  pipeline_id     = "example-pipeline"
  crypto_key_name = google_kms_crypto_key.default.id
  depends_on      = [google_kms_crypto_key_iam_member.default]
  destinations {
    topic = google_pubsub_topic.default.id
    network_config {
      network_attachment = google_compute_network_attachment.default.id
    }
    authentication_config {
      oauth_token {
        service_account = "${data.google_project.default.number}-compute@developer.gserviceaccount.com"
        scope           = "https://www.googleapis.com/auth/cloud-platform"
      }
    }
  }
}
# [END eventarc_advanced_terraform_cmek_pipeline]
