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

# [START gke_standard_zonal_arm]
resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

# [START gke_standard_zonal_arm_cluster]
resource "google_container_cluster" "default" {
  name               = "gke-standard-zonal-arm-cluster"
  location           = "us-central1-a"
  node_locations     = ["us-central1-a", "us-central1-b"]
  initial_node_count = 2

  node_config {
    machine_type    = "t2a-standard-1"
    service_account = google_service_account.default.email
  }

  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false
}
# [END gke_standard_zonal_arm_cluster]

# [START gke_standard_zonal_arm_node_pool]
resource "google_container_node_pool" "default" {
  name           = "gke-standard-zonal-arm-node-pool"
  cluster        = google_container_cluster.default.id
  node_locations = ["us-central1-f"]
  node_count     = 1

  node_config {
    machine_type = "t2a-standard-1"

    service_account = google_service_account.default.email
  }
}
# [END gke_standard_zonal_arm_node_pool]
# [END gke_standard_zonal_arm]
