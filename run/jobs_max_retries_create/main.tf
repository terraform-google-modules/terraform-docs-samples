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

# Enable Cloud Run API
resource "google_project_service" "cloudrun_api" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

#[START cloudrun_jobs_max_retries_create]
resource "google_cloud_run_v2_job" "default" {
  name         = "cloud-run-job-retries"
  location     = "us-central1"
  launch_stage = "BETA"

  template {
    template {
      max_retries = 3

      containers {
        image = "us-docker.pkg.dev/cloudrun/container/job:latest"
      }
    }
  }
}
#[END cloudrun_jobs_max_retries_create]
