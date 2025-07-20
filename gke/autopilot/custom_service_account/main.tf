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

/**
* Create an Autopilot cluster that uses a custom IAM node service account
* with the minimum role for GKE.
* Before you run this sample, create a custom service account by following
* https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster#use_least_privilege_sa
*/

# [START gke_custom_node_service_account]
resource "google_service_account" "default" {
  account_id   = "gke-node-service-account"
  display_name = "GKE node service account"
}

data "google_project" "project" {
}

resource "google_project_iam_member" "default" {
  project = data.google_project.project.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = "serviceAccount:${google_service_account.default.email}"
}
# [END gke_custom_node_service_account]

# [START gke_autopilot_custom_service_account]
resource "google_container_cluster" "default" {
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
