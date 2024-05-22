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

# [START gke_standard_secondary_boot_disk]
resource "google_container_cluster" "cluster" {
  name               = "default-cluster"
  location           = "us-central1-a"
  initial_node_count = 1
  deletion_protection = false
  min_master_version = "1.28"
}

resource "google_container_node_pool" "np" {
  name               = "default-nodepool"
  location           = "us-central1-a"
  cluster            = google_container_cluster.cluster.name
  initial_node_count = 1

  node_config {
    machine_type = "n1-standard-8"
    image_type = "COS_CONTAINERD"
	gcfs_config {
  		enabled = true
	}
    secondary_boot_disks {
      disk_image = ""
      mode = "CONTAINER_IMAGE_CACHE"
    }
  }
}
# [END gke_standard_secondary_boot_disk]