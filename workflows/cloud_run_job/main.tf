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
/*
Create a Cloud Run job that processes data files in a Cloud Storage bucket.
See https://cloud.google.com/workflows/docs/tutorials/execute-cloud-run-jobs
before running the code snippet.
*/

# [START workflows_terraform_enable_apis]
# Enable Artifact Registry API
resource "google_project_service" "artifactregistry" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

# Enable Cloud Run API
resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# Enable Cloud Storage API
resource "google_project_service" "storage" {
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

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
# [END workflows_terraform_enable_apis]

# [START workflows_terraform_iam]
# Used to retrieve project information later
data "google_project" "project" {}

# Create a dedicated service account
resource "google_service_account" "workflows" {
  account_id   = "workflows-run-job-sa"
  display_name = "Workflows Cloud Run Job Service Account"
}

# Grant permission to receive Eventarc events
resource "google_project_iam_member" "eventreceiver" {
  project = data.google_project.project.id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.workflows.email}"
}

# Grant permission to write logs
resource "google_project_iam_member" "logwriter" {
  project = data.google_project.project.id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.workflows.email}"
}

# Grant permission to execute Cloud Run jobs
resource "google_project_iam_member" "runadmin" {
  project = data.google_project.project.id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.workflows.email}"
}

# Grant permission to invoke workflows
resource "google_project_iam_member" "workflowsinvoker" {
  project = data.google_project.project.id
  role    = "roles/workflows.invoker"
  member  = "serviceAccount:${google_service_account.workflows.email}"
}

# Grant the Cloud Storage service agent permission to publish Pub/Sub topics
data "google_storage_project_service_account" "gcs_account" {}
resource "google_project_iam_member" "pubsubpublisher" {
  project = data.google_project.project.id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}

# [END workflows_terraform_iam]

# [START workflows_terraform_create_bucket]
# Cloud Storage bucket names must be globally unique
resource "random_id" "bucket_name_suffix" {
  byte_length = 4
}

# Create a Cloud Storage bucket
resource "google_storage_bucket" "default" {
  name                        = "input-${data.google_project.project.name}-${random_id.bucket_name_suffix.hex}"
  location                    = "us-central1"
  storage_class               = "STANDARD"
  force_destroy               = false
  uniform_bucket_level_access = true
}
# [END workflows_terraform_create_bucket]

# [START workflows_terraform_create_ar_repo]
# Create an Artifact Registry repository
resource "google_artifact_registry_repository" "default" {
  location      = "us-central1"
  repository_id = "my-repo"
  format        = "docker"
}
# [END workflows_terraform_create_ar_repo]

# [START workflows_terraform_create_run_job]
# Create a Cloud Run job
resource "google_cloud_run_v2_job" "default" {
  name     = "parallel-job"
  location = "us-central1"

  template {
    task_count = 10
    template {
      containers {
        image   = "us-central1-docker.pkg.dev/${data.google_project.project.name}/${google_artifact_registry_repository.default.repository_id}/parallel-job:latest"
        command = ["python"]
        args    = ["process.py"]
        env {
          name  = "INPUT_BUCKET"
          value = google_storage_bucket.default.name
        }
        env {
          name  = "INPUT_FILE"
          value = "input_file.txt"
        }
      }
    }
  }
}
# [END workflows_terraform_create_run_job]

# [START workflows_terraform_create_workflow]
# Create a workflow
resource "google_workflows_workflow" "default" {
  name        = "cloud-run-job-workflow"
  region      = "us-central1"
  description = "Workflow that routes a Cloud Storage event and executes a Cloud Run job"

  # Note that $$ is needed for Terraform
  source_contents = <<EOF
  main:
      params: [event]
      steps:
          - init:
              assign:
                  - project_id: $${sys.get_env("GOOGLE_CLOUD_PROJECT_ID")}
                  - event_bucket: $${event.data.bucket}
                  - event_file: $${event.data.name}
                  - target_bucket: $${"input-${data.google_project.project.name}-${random_id.bucket_name_suffix.hex}"}
                  - job_name: parallel-job
                  - job_location: us-central1
          - check_input_file:
              switch:
                  - condition: $${event_bucket == target_bucket}
                    next: run_job
                  - condition: true
                    next: end
          - run_job:
              call: googleapis.run.v1.namespaces.jobs.run
              args:
                  name: $${"namespaces/" + project_id + "/jobs/" + job_name}
                  location: $${job_location}
                  body:
                      overrides:
                          containerOverrides:
                              env:
                                  - name: INPUT_BUCKET
                                    value: $${event_bucket}
                                  - name: INPUT_FILE
                                    value: $${event_file}
              result: job_execution
          - finish:
              return: $${job_execution}
  EOF
}
# [END workflows_terraform_create_workflow]

# [START workflows_terraform_create_trigger]
# Create an Eventarc trigger that routes Cloud Storage events to Workflows
resource "google_eventarc_trigger" "default" {
  name     = "cloud-run-job-trigger"
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

  service_account = google_service_account.workflows.email

}
# [END workflows_terraform_create_trigger]
