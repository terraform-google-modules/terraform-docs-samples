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

# [START gke_standard_zonal_secondary_boot_disk_cluster]
resource "google_container_cluster" "default" {
  name               = "default"
  location           = "us-central1-a"
  initial_node_count = 1

  # secondary_boot_disks require GKE 1.28.3-gke.106700 or later, which should
  # be true for all release channels apart from EXTENDED.
  # If required, Use `release_channel = "EXTENDED"` and set `min_master_version`.

  # Setting `deletion_protection` to `true` would prevent
  # accidental deletion of this instance using Terraform.
  deletion_protection = false
}
# [END gke_standard_zonal_secondary_boot_disk_cluster]

# [START gke_standard_zonal_secondary_boot_disk_container]
resource "google_container_node_pool" "secondary-boot-disk-container" {
  name               = "secondary-boot-disk-container"
  location           = "us-central1-a"
  cluster            = google_container_cluster.default.name
  initial_node_count = 1

  node_config {
    machine_type = "e2-medium"
    image_type   = "COS_CONTAINERD"
    gcfs_config {
      enabled = true
    }
    secondary_boot_disks {
      disk_image = ""
      mode       = "CONTAINER_IMAGE_CACHE"
    }
  }
}
# [END gke_standard_zonal_secondary_boot_disk_container]

# [START gke_standard_zonal_secondary_boot_disk_data]
resource "google_container_node_pool" "secondary-boot-disk-data" {
  name               = "secondary-boot-disk-data"
  location           = "us-central1-a"
  cluster            = google_container_cluster.default.name
  initial_node_count = 1

  node_config {
    machine_type = "e2-medium"
    image_type   = "COS_CONTAINERD"
    gcfs_config {
      enabled = true
    }
    secondary_boot_disks {
      disk_image = ""
    }
  }
}
# [END gke_standard_zonal_secondary_boot_disk_data]
