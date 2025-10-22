/**
 * Copyright 2025 Google LLC
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
* gcloud beta compute instance-groups managed create czr-rmig \
* --region us-central1 \
* --size 3 \
* --template example-template \
* --target-distribution-shape balanced \
* --instance-redistribution-type none \
* --default-action-on-vm-failure=repair \
* --on-repair-allow-changing-zone=YES \
* --force-update-on-repair
*/

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google-beta"
      version = ">= 7.8.0"
    }
  }
}

# [START compute_rmig_cross_zone_repair_parent_tag]
resource "google_compute_instance_template" "default" {
  name         = "example-template"
  machine_type = "n2-standard-2"
  disk {
    source_image = "debian-cloud/debian-12"
  }
  network_interface {
    network = "default"
  }
}

# [START compute_rmig_cross_zone_repair]
resource "google_compute_region_instance_group_manager" "default" {
  provider           = google-beta
  name               = "example-rmig"
  base_instance_name = "example-rmig-instance"
  region             = "us-central1"

  target_size                      = 3
  distribution_policy_target_shape = "BALANCED"

  version {
    instance_template = google_compute_instance_template.default.id
  }

  instance_lifecycle_policy {
    default_action_on_failure = "REPAIR"
    force_update_on_repair    = "YES"
    on_repair {
      allow_changing_zone = "YES"
    }
  }

  update_policy {
    instance_redistribution_type = "NONE"
    type                         = "OPPORTUNISTIC"
    minimal_action               = "REPLACE"
    max_surge_fixed              = 0
    max_unavailable_fixed        = 6
  }
}
# [END compute_rmig_cross_zone_repair]
# [END compute_rmig_cross_zone_repair_parent_tag]
