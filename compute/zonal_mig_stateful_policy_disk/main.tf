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

/**
 * Made to resemble:
 * gcloud compute instance-groups managed create example-database-group \
 *  --template example-database-template-v01 \
 *  --base-instance-name shard \
 *  --size 12 \
 *  --stateful-disk device-name=data-disk,auto-delete=on-permanent-instance-deletion
 */

# [START compute_stateful_instance_group_manager_disk_policy_parent_tag]
resource "google_compute_instance_template" "default" {
  name         = "example-database-template-v01"
  machine_type = "e2-medium"
  disk {
    device_name  = "data-disk"
    source_image = "debian-cloud/debian-11"
  }
  network_interface {
    network = "default"
  }
}

# [START compute_stateful_instance_group_manager_disk_policy]
resource "google_compute_instance_group_manager" "default" {
  name               = "example-database-group"
  base_instance_name = "shard"
  target_size        = 12
  zone               = "us-central1-f"
  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }
  stateful_disk {
    device_name = "data-disk"
    delete_rule = "ON_PERMANENT_INSTANCE_DELETION"
  }
}
# [END compute_stateful_instance_group_manager_disk_policy]
# [END compute_stateful_instance_group_manager_disk_policy_parent_tag]
