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

# [START workflows_terraform_create_bucket]
# Create a Cloud Storage bucket
resource "google_storage_bucket" "default" {
  name                        = "input-PROJECT_ID"
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
  repository_id = "REPOSITORY"
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
        image   = "us-central1-docker.pkg.dev/PROJECT_ID/REPOSITORY/parallel-job:latest"
        command = ["python"]
        args    = ["process.py"]
        env {
          name  = "INPUT_BUCKET"
          value = "input-PROJECT_ID"
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
                  - target_bucket: $${"input-" + project_id}
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

  service_account = "SERVICE_ACCOUNT_NAME@PROJECT_ID.iam.gserviceaccount.com"

}
# [END workflows_terraform_create_trigger]
