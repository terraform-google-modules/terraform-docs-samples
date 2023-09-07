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

# [START eventarc_workflows_parent_tag]
# [START eventarc_terraform_workflows_enableapis]
# Enable Eventarc API
resource "google_project_service" "eventarc" {
  service            = "eventarc.googleapis.com"
  disable_on_destroy = false
}

# Enable Workflows API
resource "google_project_service" "workflows" {
  service            = "workflows.googleapis.com"
  disable_on_destroy = false
}

# Enable Pub/Sub API
resource "google_project_service" "pubsub" {
  service            = "pubsub.googleapis.com"
  disable_on_destroy = false
}
# [END eventarc_terraform_workflows_enableapis]

# [START eventarc_workflows_create_serviceaccount]
# Used to retrieve project information later
data "google_project" "project" {}

# Create a service account for Eventarc trigger and Workflows
resource "google_service_account" "eventarc" {
  account_id   = "eventarc-workflows-sa"
  display_name = "Eventarc Workflows Service Account"
}

# Grant permission to invoke workflows
resource "google_project_iam_member" "workflowsinvoker" {
  project = data.google_project.project.id
  role    = "roles/workflows.invoker"
  member  = "serviceAccount:${google_service_account.eventarc.email}"
}

# Grant permission to receive events
resource "google_project_iam_member" "eventreceiver" {
  project = data.google_project.project.id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.eventarc.email}"
}
# [END eventarc_workflows_create_serviceaccount]


# [START storage_terraform_eventarc_workflows]
# Cloud Storage bucket names must be globally unique
resource "random_id" "bucket_name_suffix" {
  byte_length = 4
}

# Create a Cloud Storage bucket
resource "google_storage_bucket" "default" {
  name          = "trigger-workflows-${data.google_project.project.name}-${random_id.bucket_name_suffix.hex}"
  location      = google_workflows_workflow.default.region
  force_destroy = true

  uniform_bucket_level_access = true
}

# Grant the Cloud Storage service account permission to publish Pub/Sub topics
data "google_storage_project_service_account" "gcs_account" {}
resource "google_project_iam_member" "pubsubpublisher" {
  project = data.google_project.project.id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}
# [END storage_terraform_eventarc_workflows]


# [START eventarc_workflows_deploy]
# Create a workflow
resource "google_workflows_workflow" "default" {
  name        = "storage-workflow-tf"
  region      = "us-central1"
  description = "Workflow that returns information about storage events"

  # Note that $$ is needed for Terraform
  source_contents = <<EOF
  main:
    params: [event]
    steps:
      - log_event:
          call: sys.log
          args:
            text: $${event}
            severity: INFO
      - gather_data:
          assign:
            - bucket: $${event.data.bucket}
            - name: $${event.data.name}
            - message: $${"Received event " + event.type + " - " + bucket + ", " + name}
      - return_data:
          return: $${message}
  EOF

  depends_on = [
    google_project_service.workflows
  ]
}
# [END eventarc_workflows_deploy]

# [START eventarc_terraform_workflows_trigger]
# Create an Eventarc trigger, routing Storage events to Workflows
resource "google_eventarc_trigger" "default" {
  name     = "trigger-storage-workflows-tf"
  location = google_workflows_workflow.default.region

  # Capture objects changed in the bucket
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.storage.object.v1.finalized"
  }
  matching_criteria {
    attribute = "bucket"
    value     = google_storage_bucket.default.name
  }

  # Send events to Workflows
  destination {
    workflow = google_workflows_workflow.default.id
  }

  service_account = google_service_account.eventarc.email

  depends_on = [
    google_project_service.eventarc,
    google_project_service.workflows,
  ]
}
# [END eventarc_terraform_workflows_trigger]
# [END eventarc_workflows_parent_tag]
