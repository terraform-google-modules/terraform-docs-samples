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


# [START compute_disk_parent_tag]
# [START compute_disk_clone_single_zone]
resource "google_compute_disk" "default" {
  name  = "disk-name1"
  type  = "pd-ssd"
  zone  = "us-central1-a"
  image = "debian-11-bullseye-v20220719"
  labels = {
    environment = "dev"
  }
  physical_block_size_bytes = 4096
}
# [END compute_disk_clone_single_zone]

# [START compute_snapshot_create]
resource "google_compute_snapshot" "snapdisk" {
  name        = "snapshot-name"
  source_disk = google_compute_disk.default.name
  zone        = "us-central1-a"
}
# [END compute_snapshot_create]

# [START compute_disk_clone_regional]
resource "google_compute_region_disk" "regiondisk" {
  name                      = "region-disk-name"
  snapshot                  = google_compute_snapshot.snapdisk.id
  type                      = "pd-ssd"
  region                    = "us-central1"
  physical_block_size_bytes = 4096
  size                      = 11

  replica_zones = ["us-central1-a", "us-central1-f"]
}
# [END compute_disk_clone_regional]
# [END compute_disk_parent_tag]
