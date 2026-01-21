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

# [START eventarc_advanced_parent_tag]
# [START eventarc_terraform_advanced_enableapis]
# Enable APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "eventarc.googleapis.com",
    "eventarcpublishing.googleapis.com",
    "run.googleapis.com"
  ])
  service            = each.key
  disable_on_destroy = false
}
# [END eventarc_terraform_advanced_enableapis]

# [START eventarc_terraform_advanced_iam]
# Used to retrieve project information later
data "google_project" "project" {}

# Create a dedicated service account
resource "google_service_account" "eventarc" {
  account_id   = "eventarc-advanced-sa"
  display_name = "Eventarc Advanced quickstart service account"
}

# Grant permission to receive Eventarc events
resource "google_project_iam_member" "eventreceiver" {
  project = data.google_project.project.id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.eventarc.email}"
}

# Grant permission to invoke Cloud Run services
resource "google_project_iam_member" "runinvoker" {
  project = data.google_project.project.id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.eventarc.email}"
}
# [END eventarc_terraform_advanced_iam]

# [START eventarc_terraform_advanced_deploy_run]
# Deploy Cloud Run service
resource "google_cloud_run_v2_service" "default" {
  name     = "example-service"
  location = "us-central1"

  deletion_protection = false # set to "true" in production

  template {
    containers {
      # This container will log received events
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
    service_account = google_service_account.eventarc.email
  }

  depends_on = [google_project_service.apis]
}
# [END eventarc_terraform_advanced_deploy_run]

# [START eventarc_terraform_advanced_bus]
# Create an Eventarc Advanced bus
resource "google_eventarc_message_bus" "default" {
  location        = "us-central1"
  message_bus_id  = "example-bus"
}
# [END eventarc_terraform_advanced_bus]

# [START eventarc_terraform_advanced_google_source]
# Enable events from Google API sources
resource "google_eventarc_google_api_source" "default" {
  location             = "us-central1"
  google_api_source_id = "example-google-api-source"
  destination          = google_eventarc_message_bus.default.id
}
# [END eventarc_terraform_advanced_google_source]

# [START eventarc_terraform_advanced_pipeline]
# Create an Eventarc Advanced pipeline
resource "google_eventarc_pipeline" "default" {
  location    = "us-central1"
  pipeline_id = "example-pipeline"
  destinations {
    http_endpoint {
      uri = google_cloud_run_v2_service.default.uri
    }
    authentication_config {
      google_oidc {
        service_account = google_service_account.eventarc.email
      }
    }
  }
}
# [END eventarc_terraform_advanced_pipeline]

# [START eventarc_terraform_advanced_enrollment]
# Create an Eventarc Advanced enrollment
resource "google_eventarc_enrollment" "default" {
  location      = "us-central1"
  enrollment_id = "example-enrollment"
  message_bus   = google_eventarc_message_bus.default.id
  destination   = google_eventarc_pipeline.default.id
  cel_match     = "message.type == 'google.cloud.workflows.workflow.v1.created'"
}
# [END eventarc_terraform_advanced_enrollment]
# [END eventarc_advanced_parent_tag]
