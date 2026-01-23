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

# [START eventarc_basic_pubsub_parent_tag]
# [START eventarc_basic_pubsub_enableapis]
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
# [END eventarc_basic_pubsub_enableapis]

# [START eventarc_basic_pubsub_iam]
# Used to retrieve project information later
data "google_project" "project" {}

# Create a dedicated service account
resource "google_service_account" "eventarc" {
  account_id   = "eventarc-trigger-sa"
  display_name = "Eventarc trigger service account"
}

# [START eventarc_basic_pubsub_topic]
# Create a Pub/Sub topic
resource "google_pubsub_topic" "default" {
  name = "pubsub_topic"
}
# [END eventarc_basic_pubsub_topic]

# Grant permission to publish messages to a Pub/Sub topic
resource "google_pubsub_topic_iam_member" "pubsubpublisher" {
  project    = data.google_project.project.id
  topic      = google_pubsub_topic.default.name
  member     = "serviceAccount:${google_service_account.eventarc.email}"
  role       = "roles/pubsub.publisher"
  depends_on = [google_pubsub_topic.default]
}
# [END eventarc_basic_pubsub_iam]

# [START eventarc_basic_pubsub_deploy_cloud_run]
# Deploy a Cloud Run service
resource "google_cloud_run_v2_service" "default" {
  name     = "hello-events"
  location = "us-central1"

  deletion_protection = false # set to "true" in production

  template {
    containers {
      # This container will log received events
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
    service_account = google_service_account.eventarc.email
  }

  depends_on = [google_project_service.run]
}
# [END eventarc_basic_pubsub_deploy_cloud_run]

# Grant permission to invoke Cloud Run services
resource "google_cloud_run_v2_service_iam_member" "runinvoker" {
  project    = data.google_project.project.id
  name       = google_cloud_run_v2_service.default.name
  role       = "roles/run.invoker"
  member     = "serviceAccount:${google_service_account.eventarc.email}"
  depends_on = [google_cloud_run_v2_service.default]
}

# [START eventarc_basic_pubsub_trigger]
# Create an Eventarc trigger, routing Pub/Sub events to Cloud Run
resource "google_eventarc_trigger" "default" {
  name     = "trigger-pubsub-cloudrun-tf"
  location = google_cloud_run_v2_service.default.location

  # Capture messages published to a Pub/Sub topic
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }

  # Send events to Cloud Run
  destination {
    cloud_run_service {
      service = google_cloud_run_v2_service.default.name
      region  = google_cloud_run_v2_service.default.location
    }
  }

  transport {
    pubsub {
      topic = google_pubsub_topic.default.id
    }
  }

  service_account = google_service_account.eventarc.email
  depends_on = [
    google_project_service.eventarc,
    google_pubsub_topic_iam_member.pubsubpublisher
  ]
}
# [END eventarc_basic_pubsub_trigger]
# [END eventarc_basic_pubsub_parent_tag]
