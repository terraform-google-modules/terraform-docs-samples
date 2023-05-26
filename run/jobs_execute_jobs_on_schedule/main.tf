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

provider "google-beta" {
  region = "us-central1"
}

# Project data
# [START cloudrun_jobs_execute_jobs_on_schedule_parent_tag]
data "google_project" "project" {
}

# Enable Cloud Run API
resource "google_project_service" "cloudrun_api" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
  project            = data.google_project.project.project_id
}

# Enable Compute Engine API
resource "google_project_service" "computeengine_api" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
  project            = data.google_project.project.project_id
}

# Enable Cloud Scheduler API
resource "google_project_service" "cloudscheduler_api" {
  service            = "cloudscheduler.googleapis.com"
  disable_on_destroy = false
  project            = data.google_project.project.project_id
}

# Cloud Run Invoker Service Account
resource "google_service_account" "cloud_run_invoker_sa" {
  account_id   = "cloud-run-invoker"
  display_name = "Cloud Run Invoker"
  provider     = google-beta
  project      = data.google_project.project.project_id
}

# Project IAM binding
resource "google_project_iam_binding" "run_invoker_binding" {
  project = data.google_project.project.project_id
  role    = "roles/run.invoker"
  members = ["serviceAccount:${google_service_account.cloud_run_invoker_sa.email}"]
}

resource "google_project_iam_binding" "token_creator_binding" {
  project = data.google_project.project.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  members = ["serviceAccount:${google_service_account.cloud_run_invoker_sa.email}"]
}

# Cloud Run Job
resource "google_cloud_run_v2_job" "default" {
  provider     = google-beta
  name         = "cloud-run-job"
  location     = "us-central1"
  launch_stage = "BETA"
  project      = data.google_project.project.project_id

  template {
    template {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/job:latest"
      }
    }
  }

  depends_on = [resource.google_project_service.cloudrun_api]
}

# Cloud Run Job IAM binding
resource "google_cloud_run_v2_job_iam_binding" "binding" {
  project    = data.google_project.project.project_id
  location   = google_cloud_run_v2_job.default.location
  name       = google_cloud_run_v2_job.default.name
  role       = "roles/viewer"
  members    = ["serviceAccount:${google_service_account.cloud_run_invoker_sa.email}"]
  depends_on = [resource.google_cloud_run_v2_job.default]
}

#[START cloud_run_jobs_execute_jobs_on_schedule]
resource "google_cloud_scheduler_job" "job" {
  provider         = google-beta
  name             = "schedule-job"
  description      = "test http job"
  schedule         = "*/8 * * * *"
  attempt_deadline = "320s"
  region           = "us-central1"
  project          = data.google_project.project.project_id

  retry_config {
    retry_count = 3
  }

  http_target {
    http_method = "POST"
    uri         = "https://${google_cloud_run_v2_job.default.location}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${data.google_project.project.number}/jobs/${google_cloud_run_v2_job.default.name}:run"

    oauth_token {
      service_account_email = google_service_account.cloud_run_invoker_sa.email
    }
  }

  depends_on = [resource.google_project_service.cloudscheduler_api, resource.google_cloud_run_v2_job.default, resource.google_cloud_run_v2_job_iam_binding.binding]
}
#[END cloud_run_jobs_execute_jobs_on_schedule]
# [END cloudrun_jobs_execute_jobs_on_schedule_parent_tag]