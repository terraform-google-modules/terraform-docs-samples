/**
* Copyright 2025 Google LLC
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

# Create an Autopilot cluster with a custom IAM node service account 

# [START gke_node_service_account_create]
resource "google_service_account" "default" {
  account_id   = "gke-node-service-account"
  display_name = "GKE node service account"
}
# [END gke_node_service_account_create]

# [START gke_node_service_account_role]
data "google_project" "project" {
}

resource "google_project_iam_member" "project_role" {
  project = data.google_project.project.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = "serviceAccount:${google_service_account.default.email}"
}
# [END gke_node_service_account_role]


# [START gke_autopilot_custom_service_account]
resource "google_container_cluster" "autopilot_cluster" {
  name     = "autopilot-custom-account"
  location = "us-central1"

  enable_autopilot = true

  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = google_service_account.default.email
    }
  }
}
# [END gke_autopilot_custom_service_account]
