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
# Project data
data "google_project" "project" {
}

# Enable Cloud Run API
resource "google_project_service" "cloudrun_api" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# [START cloudrun_service_pubsub_service]
resource "google_cloud_run_service" "default" {
  name     = "pubsub-tutorial"
  location = "us-central1"
  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello" # Replace with newly created image gcr.io/<project_id>/pubsub
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
  depends_on = [google_project_service.cloudrun_api]
}
# [END cloudrun_service_pubsub_service]

# [START cloudrun_service_pubsub_sa]
resource "google_service_account" "sa" {
  account_id   = "cloud-run-pubsub-invoker"
  display_name = "Cloud Run Pub/Sub Invoker"
}
# [END cloudrun_service_pubsub_sa]

# [START cloudrun_service_pubsub_run_invoke_permissions]
resource "google_cloud_run_service_iam_binding" "binding" {
  location = google_cloud_run_service.default.location
  service  = google_cloud_run_service.default.name
  role     = "roles/run.invoker"
  members  = ["serviceAccount:${google_service_account.sa.email}"]
}
# [END cloudrun_service_pubsub_run_invoke_permissions]

# [START cloudrun_service_pubsub_token_permissions]
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
# [END cloudrun_service_pubsub_token_permissions]

# [START cloudrun_service_pubsub_topic]
resource "google_pubsub_topic" "default" {
  name = "pubsub_topic"
}
# [END cloudrun_service_pubsub_topic]

# [START cloudrun_service_pubsub_sub]
resource "google_pubsub_subscription" "subscription" {
  name  = "pubsub_subscription"
  topic = google_pubsub_topic.default.name
  push_config {
    push_endpoint = google_cloud_run_service.default.status[0].url
    oidc_token {
      service_account_email = google_service_account.sa.email
    }
    attributes = {
      x-goog-version = "v1"
    }
  }
  depends_on = [google_cloud_run_service.default]
}
# [END cloudrun_service_pubsub_sub]
