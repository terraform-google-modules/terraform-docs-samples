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

# [START compute_disk_consistency_group_attachment_parent_tag]

# [START compute_resource_policy]
resource "google_compute_resource_policy" "default" {
  name   = "test-consistency-group"
  region = "us-central1"
  disk_consistency_group_policy {
    enabled = true
  }
}
# [END compute_resource_policy]

# [START compute_disk_ssd]
resource "google_compute_disk" "default" {
  name = "test-ssd-disk"
  type = "pd-ssd"
  zone = "us-central1-a"
  size = "5"
}
# [END compute_disk_ssd]

# [START compute_disk_resource_policy_attachment]
resource "google_compute_disk_resource_policy_attachment" "default" {
  name = google_compute_resource_policy.default.name
  disk = google_compute_disk.default.name
  zone = "us-central1-a"
}
# [END compute_disk_resource_policy_attachment]

# [END compute_disk_consistency_group_attachment_parent_tag]
