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

resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_container_cluster" "default" {
  name     = "gke-standard-regional-cluster"
  location = "us-central1"

  initial_node_count       = 1
  remove_default_node_pool = true

  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false
}

# [START gke_standard_regional_node_pool]
resource "google_container_node_pool" "default" {
  name    = "gke-standard-regional-node-pool"
  cluster = google_container_cluster.default.name

  node_config {
    service_account = google_service_account.default.email
  }
}
# [END gke_standard_regional_node_pool]
