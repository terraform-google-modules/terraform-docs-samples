/**
 * Copyright 2022 Google LLC
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

# [START primary_disk_setup_for_async_replication]
resource "google_compute_disk" "primary-disk" {
  name = "primary-disk"
  type = "pd-ssd"
  zone = "europe-west4-a"

  physical_block_size_bytes = 4096
}
# [END primary_disk_setup_for_async_replication]

# [START secondary_disk_setup_for_async_replication]
resource "google_compute_disk" "secondary-disk" {
  name = "secondary-disk"
  type = "pd-ssd"
  zone = "europe-west3-a"

  async_primary_disk {
    disk = google_compute_disk.primary-disk.id
  }

  physical_block_size_bytes = 4096
}
# [END secondary_disk_setup_for_async_replication]


# [START setup_to_start_asynchronous_replication]
resource "google_compute_disk_async_replication" "replication" {
  primary_disk = google_compute_disk.primary-disk.id
  secondary_disk {
    disk = google_compute_disk.secondary-disk.id
  }
}
# [END setup_to_start_asynchronous_replication]

