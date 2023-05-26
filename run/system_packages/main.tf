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

# Example of how to deploy a Cloud Run application with system packages

# [START cloudrun_system_packages_parent_tag]
# [START cloudrun_system_packages]
resource "google_service_account" "graphviz" {
  account_id   = "graphviz"
  display_name = "GraphViz Tutorial Service Account"
}

resource "google_cloud_run_service" "default" {
  name     = "graphviz-example"
  location = "us-central1"

  template {
    spec {
      containers {
        # Replace with the URL of your graphviz image
        #   gcr.io/<YOUR_GCP_PROJECT_ID>/graphviz
        image = "gcr.io/cloudrun/hello"
      }

      service_account_name = google_service_account.graphviz.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
# [END cloudrun_system_packages]

# [START cloudrun_system_packages_allow_unauthenticated]
# Make Cloud Run service publicly accessible
resource "google_cloud_run_service_iam_member" "allow_unauthenticated" {
  service  = google_cloud_run_service.default.name
  location = google_cloud_run_service.default.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
# [END cloudrun_system_packages_allow_unauthenticated]
# [END cloudrun_system_packages_parent_tag]