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

# [START gke_standard_regional_ray_operator]
resource "google_container_cluster" "ray-cluster" {
  name     = "gke-standard-regional-ray-operator"
  location = "us-west1"

  initial_node_count = 1

  release_channel {
    channel = "RAPID"
  }

  addons_config {
    ray_operator_config {
      enabled = true
      ray_cluster_logging_config {
        enabled = true
      }
      ray_cluster_monitoring_config {
        enabled = true
      }
    }
  }

  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false
}
# [END gke_standard_regional_ray_operator]
