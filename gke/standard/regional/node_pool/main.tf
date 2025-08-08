/**
* Copyright 2024 Google LLC
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

# [START gke_standard_regional_node_pool_custom_sa]
resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

data "google_project" "project" {
}

resource "google_project_iam_member" "default" {
  project = data.google_project.project.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = "serviceAccount:${google_service_account.default.email}"
}
# [END gke_standard_regional_node_pool_custom_sa]

# [START gke_standard_regional_cluster]
resource "google_container_cluster" "default" {
  name     = "gke-standard-regional-cluster"
  location = "us-central1"

  initial_node_count       = 1
  remove_default_node_pool = true
}
# [END gke_standard_regional_cluster]

# [START gke_standard_regional_node_pool]
resource "google_container_node_pool" "default" {
  name    = "gke-standard-regional-node-pool"
  cluster = google_container_cluster.default.name

  node_config {
    service_account = google_service_account.default.email
  }
}
# [END gke_standard_regional_node_pool]
