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

# [START gke_standard_regional_windows]
# [START gke_standard_regional_windows_cluster]
resource "google_container_cluster" "default" {
  name     = "gke-standard-regional-cluster"
  location = "us-west1"

  initial_node_count = 1

  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false
}
# [END gke_standard_regional_windows_cluster]

# [START gke_standard_regional_windows_node_pool]
resource "google_container_node_pool" "default" {
  name     = "windows-node-pool"
  cluster  = google_container_cluster.default.name
  location = google_container_cluster.default.location

  node_config {
    image_type = "WINDOWS_LTSC_CONTAINERD"
  }
}
# [END gke_standard_regional_windows_node_pool]
# [END gke_standard_regional_windows]
