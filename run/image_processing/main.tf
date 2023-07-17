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

# [START cloudrun_image_processing_parent_tag]
# [START cloudrun_service_existing_pubsub]
resource "google_service_account" "sa" {
  account_id   = "cloud-run-pubsub-invoker"
  display_name = "Cloud Run Pub/Sub Invoker"
}

resource "google_cloud_run_service_iam_binding" "binding" {
  location = google_cloud_run_v2_service.default.location
  service  = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  members  = ["serviceAccount:${google_service_account.sa.email}"]
}

data "google_project" "project" {
}

resource "google_project_service_identity" "pubsub_agent" {
  provider = google-beta
  project  = data.google_project.project.project_id
  service  = "pubsub.googleapis.com"
}

resource "google_project_iam_binding" "project_token_creator" {
  project = data.google_project.project.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  members = ["serviceAccount:${google_project_service_identity.pubsub_agent.email}"]
}

resource "google_pubsub_topic" "default" {
  name = "pubsub_topic"
}

resource "google_pubsub_subscription" "subscription" {
  name  = "pubsub_subscription"
  topic = google_pubsub_topic.default.name
  push_config {
    push_endpoint = google_cloud_run_v2_service.default.uri
    oidc_token {
      service_account_email = google_service_account.sa.email
    }
    attributes = {
      x-goog-version = "v1"
    }
  }
}
# [END cloudrun_service_existing_pubsub]

# [START cloudrun_service_image_processing_buckets]
resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "google_storage_bucket" "imageproc_input" {
  name     = "input-bucket-${random_id.bucket_suffix.hex}"
  location = "us-central1"
}

output "input_bucket_name" {
  value = google_storage_bucket.imageproc_input.name
}

resource "google_storage_bucket" "imageproc_output" {
  name     = "output-bucket-${random_id.bucket_suffix.hex}"
  location = "us-central1"
}

output "blurred_bucket_name" {
  value = google_storage_bucket.imageproc_output.name
}

# [END cloudrun_service_image_processing_buckets]

# [START cloudrun_service_image_processing_crservice]
resource "google_cloud_run_v2_service" "default" {
  name     = "pubsub-tutorial"
  location = "us-central1"
  template {
    containers {

      # Replace with newly created image gcr.io/<project_id>/pubsub
      image = "gcr.io/cloudrun/hello"
      env {
        name  = "BLURRED_BUCKET_NAME"
        value = google_storage_bucket.imageproc_output.name
      }
    }
  }
}
# [END cloudrun_service_image_processing_crservice]

# [START cloudrun_service_image_processing_notifications]
data "google_storage_project_service_account" "gcs_account" {}

resource "google_pubsub_topic_iam_binding" "binding" {
  topic   = google_pubsub_topic.default.name
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}

resource "google_storage_notification" "notification" {
  bucket         = google_storage_bucket.imageproc_input.name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.default.id
  depends_on     = [google_pubsub_topic_iam_binding.binding]
}
# [END cloudrun_service_image_processing_notifications]
# [END cloudrun_image_processing_parent_tag]
