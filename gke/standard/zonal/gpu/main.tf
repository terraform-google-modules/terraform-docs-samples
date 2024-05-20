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

# [START gke_standard_zonal_gpu]
resource "google_container_cluster" "default" {
  name               = "gke-standard-zonal-gpu"
  location           = "us-central1-a"
  initial_node_count = 1

  node_config {
    guest_accelerator {
      type               = "nvidia-tesla-t4"
      count              = 1
      gpu_driver_installation_config {
        gpu_driver_version = "LATEST"
      }
    }
    machine_type = "n1-standard-2"
  }

  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false
}
# [END gke_standard_zonal_gpu]
