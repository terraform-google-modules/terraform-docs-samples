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

# [START cloudrun_service_tasks_service]
resource "google_cloud_run_service" "default" {
  name     = "cloud-run-service-name"
  location = "us-central1"
  provider = google-beta
  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}
# [END cloudrun_service_tasks_service]

# [START cloudrun_service_tasks_sa]
resource "google_service_account" "sa" {
  account_id   = "cloud-run-task-invoker"
  display_name = "Cloud Run Task Invoker"
  provider     = google-beta
}
# [END cloudrun_service_tasks_sa]

# [START cloudrun_service_tasks_run_invoke_permissions]
resource "google_cloud_run_service_iam_binding" "binding" {
  location = google_cloud_run_service.default.location
  service  = google_cloud_run_service.default.name
  role     = "roles/run.invoker"
  members  = ["serviceAccount:${google_service_account.sa.email}"]
  provider = google-beta
  project  = google_cloud_run_service.default.project
}
# [END cloudrun_service_tasks_run_invoke_permissions]

# [START cloudrun_service_tasks_token_permissions]
resource "google_project_iam_binding" "project_binding" {
  role     = "roles/iam.serviceAccountTokenCreator"
  members  = ["serviceAccount:${google_service_account.sa.email}"]
  provider = google-beta
  project  = google_cloud_run_service.default.project
}
# [END cloudrun_service_tasks_token_permissions]

# [START cloudrun_service_tasks_queue]
resource "google_cloud_tasks_queue" "default" {
  name     = "cloud-tasks-queue-name"
  location = "us-central1"
  provider = google-beta
}
# [END cloudrun_service_tasks_queue]
