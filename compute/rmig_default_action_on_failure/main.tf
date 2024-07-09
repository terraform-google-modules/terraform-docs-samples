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
 * Made to resemble
 * gcloud compute instance-groups managed create rmig-daof \
 *   --template=template \
 *   --size=3 \
 *   --region=us-central1 \
 *   --default-action-on-vm-failure=repair
 */
# [START compute_regional_instance_group_manager_daof_parent_tag]
resource "google_compute_instance_template" "default" {
  name         = "template"
  machine_type = "e2-medium"

  disk {
    source_image = "debian-cloud/debian-11"
  }

  network_interface {
    network = "default"
  }
}
# [START compute_regional_instance_group_manager_daof_tag]
resource "google_compute_region_instance_group_manager" "default" {
  name               = "rmig-daof"
  base_instance_name = "test"
  target_size        = 3
  region             = "us-central1"

  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }

  instance_lifecycle_policy {
    default_action_on_failure = "REPAIR"
  }
}
# [END compute_regional_instance_group_manager_daof_tag]
# [END compute_regional_instance_group_manager_daof_parent_tag]
