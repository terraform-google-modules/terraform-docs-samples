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

# [START eventarc_basic_parent_tag]
# [START eventarc_terraform_basic_enableapis]
# Enable Cloud Run API
resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# Enable Eventarc API
resource "google_project_service" "eventarc" {
  service            = "eventarc.googleapis.com"
  disable_on_destroy = false
}

# Enable Pub/Sub API
resource "google_project_service" "pubsub" {
  service            = "pubsub.googleapis.com"
  disable_on_destroy = false
}
# [END eventarc_terraform_basic_enableapis]


# [START eventarc_terraform_basic_iam]
# Used to retrieve project information later
data "google_project" "project" {}

# Create a dedicated service account
resource "google_service_account" "default" {
  account_id   = "eventarc-trigger-sa"
  display_name = "Eventarc Trigger Service Account"
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
# [END eventarc_terraform_basic_iam]


# [START storage_terraform_eventarc_cloudrun]
# Cloud Storage bucket names must be globally unique
resource "random_id" "bucket_name_suffix" {
  byte_length = 4
}

# Create a Cloud Storage bucket
resource "google_storage_bucket" "default" {
  name          = "trigger-cloudrun-${data.google_project.project.name}-${random_id.bucket_name_suffix.hex}"
  location      = google_cloud_run_v2_service.default.location
  force_destroy = true

  uniform_bucket_level_access = true
}

# Grant the Cloud Storage service account permission to publish pub/sub topics
data "google_storage_project_service_account" "gcs_account" {}
resource "google_project_iam_member" "pubsubpublisher" {
  project = data.google_project.project.id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}
# [END storage_terraform_eventarc_cloudrun]


# [START cloudrun_terraform_deploy_eventarc]
# Deploy Cloud Run service
resource "google_cloud_run_v2_service" "default" {
  name     = "hello-events"
  location = "us-central1"

  deletion_protection = false # set to "true" in production

  template {
    containers {
      # This container will log received events
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
    service_account = google_service_account.default.email
  }

  depends_on = [google_project_service.run]
}
# [END cloudrun_terraform_deploy_eventarc]


# [START eventarc_terraform_cloudrun_trigger]
# Create an Eventarc trigger, routing Cloud Storage events to Cloud Run
resource "google_eventarc_trigger" "default" {
  name     = "trigger-storage-cloudrun-tf"
  location = google_cloud_run_v2_service.default.location

  # Capture objects changed in the bucket
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.storage.object.v1.finalized"
  }
  matching_criteria {
    attribute = "bucket"
    value     = google_storage_bucket.default.name
  }

  # Send events to Cloud Run
  destination {
    cloud_run_service {
      service = google_cloud_run_v2_service.default.name
      region  = google_cloud_run_v2_service.default.location
    }
  }

  # Specify a single delivery attempt with no retries
  retry_policy {
    max_attempts = 1
  }

  service_account = google_service_account.default.email
  depends_on = [
    google_project_service.eventarc,
    google_storage_bucket.default,
    google_project_iam_member.pubsubpublisher
  ]
}
# [END eventarc_terraform_cloudrun_trigger]
# [END eventarc_basic_parent_tag]
