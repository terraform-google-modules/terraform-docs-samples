/**
 * Copyright 2026 Google LLC
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
resource "google_project_service" "apis" {
  for_each = toset([
    "cloudkms.googleapis.com",
    "eventarc.googleapis.com",
    "eventarcpublishing.googleapis.com"
  ])
  service            = each.key
  disable_on_destroy = false
}
# [END eventarc_advanced_terraform_cmek_apis]

# Enable Cloud Run API
# Destination is a Cloud Run service and is required to create pipeline
resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# Create a dedicated service account
resource "google_service_account" "default" {
  account_id   = "eventarc-advanced-sa"
  display_name = "Eventarc Advanced dedicated service account"
}

# Grant permission to receive Eventarc events
resource "google_project_iam_member" "eventreceiver" {
  project = data.google_project.project.id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.default.email}"
}

# Grant permission to invoke Cloud Run services
resource "google_project_iam_member" "runinvoker" {
  project = data.google_project.project.id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.default.email}"
}

# Deploy Cloud Run service
resource "google_cloud_run_v2_service" "default" {
  name                = "example-service"
  location            = "us-central1"
  deletion_protection = false # set to "true" in production
  ingress             = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  template {
    containers {
      # This sample container listens to HTTP requests and logs received events
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
    service_account = google_service_account.default.email
  }
  depends_on = [google_project_service.run]
}

# Used to retrieve project information later
data "google_project" "project" {}

# [START eventarc_advanced_terraform_service_agent]
resource "google_project_service_identity" "eventarc_sa" {
  provider = google-beta
  project  = data.google_project.project.project_id
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

# [START eventarc_advanced_terraform_cmek_pipeline]
# Enable CMEK for an Eventarc Advanced pipeline
resource "google_eventarc_pipeline" "default" {
  location    = "us-central1"
  pipeline_id = "example-pipeline"
  destinations {
    http_endpoint {
      uri = google_cloud_run_v2_service.default.uri
    }
    authentication_config {
      google_oidc {
        service_account = google_service_account.default.email
      }
    }
  }
  crypto_key_name = google_kms_crypto_key.default.id
}
# [END eventarc_advanced_terraform_cmek_pipeline]
