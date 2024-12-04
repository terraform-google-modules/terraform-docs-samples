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

# [START compute_disk_async_replication_parent_tag]
# [START compute_disk_primary]
resource "google_compute_disk" "primary_disk" {
  name = "primary-disk"
  type = "pd-ssd"
  zone = "europe-west4-a"

  physical_block_size_bytes = 4096
}
# [END compute_disk_primary]

# [START compute_disk_secondary]
resource "google_compute_disk" "secondary_disk" {
  name = "secondary-disk"
  type = "pd-ssd"
  zone = "europe-west3-a"

  async_primary_disk {
    disk = google_compute_disk.primary_disk.id
  }

  physical_block_size_bytes = 4096
}
# [END compute_disk_secondary]


# [START compute_disk_async_replication]
resource "google_compute_disk_async_replication" "default" {
  primary_disk = google_compute_disk.primary_disk.id
  secondary_disk {
    disk = google_compute_disk.secondary_disk.id
  }
}
# [END compute_disk_async_replication]
# [END compute_disk_async_replication_parent_tag]
