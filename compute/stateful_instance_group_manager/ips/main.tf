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
 * gcloud compute instance-groups managed create example-group \
 *    --region us-east1 \
 *    --template node-template \
 *    --base-instance-name node \
 *    --instance-redistribution-type NONE \
 *    --size 3 \
 *    --stateful-internal-ip interface-name=nic0,auto-delete=on-permanent-instance-deletion
 *    --stateful-internal-ip interface-name=nic1,auto-delete=on-permanent-instance-deletion
 *    --stateful-external-ip enabled,auto-delete=on-permanent-instance-deletion
 */

# [START compute_stateful_instance_group_manager_ips_policy_parent_tag]
resource "google_compute_network" "default" {
  name = "my-network"
}

resource "google_compute_instance_template" "default" {
  name         = "node-template"
  machine_type = "e2-medium"

  disk {
    source_image = "debian-cloud/debian-11"
  }

  network_interface {
    network = "default"
  }
  network_interface {
    network = google_compute_network.default.id
  }
}

# [START compute_stateful_instance_group_manager_ips_policy]
resource "google_compute_region_instance_group_manager" "default" {
  name               = "example-group"
  base_instance_name = "node"
  target_size        = 3
  region             = "us-east1"

  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }
  update_policy {
    type                         = "OPPORTUNISTIC"
    minimal_action               = "REFRESH"
    instance_redistribution_type = "NONE"
    max_unavailable_fixed        = 3
  }
  stateful_internal_ip {
    interface_name = "nic0"
    delete_rule    = "ON_PERMANENT_INSTANCE_DELETION"
  }
  stateful_internal_ip {
    interface_name = "nic1"
    delete_rule    = "ON_PERMANENT_INSTANCE_DELETION"
  }
  stateful_external_ip {
    interface_name = "nic0"
    delete_rule    = "ON_PERMANENT_INSTANCE_DELETION"
  }
}
# [END compute_stateful_instance_group_manager_ips_policy]
# [END compute_stateful_instance_group_manager_ips_policy_parent_tag]
