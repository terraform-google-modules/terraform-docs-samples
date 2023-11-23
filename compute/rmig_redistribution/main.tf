/**
 * Copyright 2023 Google LLC
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
 * gcloud compute instance-groups managed create example-rmig \
 *   --template example-template \
 *   --size 30 \
 *   --zones us-east1-b,us-east1-c \
 *   --instance-redistribution-type NONE
 */

# [START compute_region_igm_redistribution_parent_tag]
resource "google_compute_instance_template" "default" {
  name         = "example-template"
  machine_type = "e2-medium"
  disk {
    source_image = "debian-cloud/debian-11"
  }
  network_interface {
    network = "default"
  }
}

# [START compute_region_igm_redistribution]
resource "google_compute_region_instance_group_manager" "default" {
  name                      = "example-rmig"
  region                    = "us-east1"
  distribution_policy_zones = ["us-east1-b", "us-east1-c"]
  update_policy {
    type                         = "PROACTIVE"
    minimal_action               = "REFRESH"
    instance_redistribution_type = "NONE"
    max_unavailable_fixed        = 3
  }
  target_size        = 30
  base_instance_name = "instance"
  version {
    instance_template = google_compute_instance_template.default.id
  }
}
# [END compute_region_igm_redistribution]
# [END compute_region_igm_redistribution_parent_tag]
