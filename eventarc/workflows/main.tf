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

# [START eventarc_workflows_parent_tag]
# [START eventarc_terraform_enableapis]
# Used to retrieve project_number later
data "google_project" "project" {
  provider = google
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

# Enable Workflows API
resource "google_project_service" "workflows" {
  service            = "workflows.googleapis.com"
  disable_on_destroy = false
}

# [END eventarc_terraform_enableapis]

# [START eventarc_workflows_create_serviceaccount]

# Create a service account for Eventarc trigger and Workflows
resource "google_service_account" "eventarc_workflows_service_account" {
  account_id   = "eventarc-workflows-sa"
  display_name = "Eventarc Workflows Service Account"
}

# Grant the logWriter role to the service account
resource "google_project_iam_binding" "project_binding_eventarc" {
  project = data.google_project.project.id
  role    = "roles/logging.logWriter"

  members = ["serviceAccount:${google_service_account.eventarc_workflows_service_account.email}"]

  depends_on = [google_service_account.eventarc_workflows_service_account]
}

# Grant the workflows.invoker role to the service account
resource "google_project_iam_binding" "project_binding_workflows" {
  project = data.google_project.project.id
  role    = "roles/workflows.invoker"

  members = ["serviceAccount:${google_service_account.eventarc_workflows_service_account.email}"]

  depends_on = [google_service_account.eventarc_workflows_service_account]
}

# [END eventarc_workflows_create_serviceaccount]

# [START eventarc_workflows_deploy]
# Define and deploy a workflow
resource "google_workflows_workflow" "workflows_example" {
  name            = "pubsub-workflow-tf"
  region          = "us-central1"
  description     = "A sample workflow"
  service_account = google_service_account.eventarc_workflows_service_account.email
  # Imported main workflow template file
  source_contents = templatefile("workflow.tftpl", {})

  depends_on = [google_project_service.workflows,
  google_service_account.eventarc_workflows_service_account]
}

# [END eventarc_workflows_deploy]

# [START eventarc_create_pubsub_trigger]
# Create an Eventarc trigger routing Pub/Sub events to Workflows
resource "google_eventarc_trigger" "trigger_pubsub_tf" {
  name     = "trigger-pubsub-workflow-tf"
  location = "us-central1"

  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }
  destination {
    workflow = google_workflows_workflow.workflows_example.id
  }

  service_account = google_service_account.eventarc_workflows_service_account.email

  depends_on = [google_project_service.pubsub, google_project_service.eventarc,
  google_service_account.eventarc_workflows_service_account]
}

# [END eventarc_create_pubsub_trigger]
# [END eventarc_workflows_parent_tag]
