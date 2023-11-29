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
 * gcloud compute instance-groups managed create-instance proxy-cluster \
 *    --instance proxy-node-03 \
 *    --stateful-internal-ip address="projects/example-project/regions/us-east1/addresses/proxy-node-03-ip",auto-delete=never
 */

# [START compute_stateful_instance_group_manager_ips_parent_tag]
resource "google_compute_instance_template" "default" {
  machine_type = "e2-medium"

  disk {
    source_image = "debian-cloud/debian-11"
  }

  network_interface {
    network = "default"
  }
}

resource "google_compute_address" "default" {
  name         = "my-internal-address"
  region       = "us-east1"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
}

resource "google_compute_region_instance_group_manager" "default" {
  name               = "proxy-cluster"
  base_instance_name = "test"
  target_size        = 1
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
}
# [START compute_stateful_instance_group_manager_ips_pic]
resource "google_compute_region_per_instance_config" "default" {
  region_instance_group_manager = google_compute_region_instance_group_manager.default.name
  region                        = google_compute_region_instance_group_manager.default.region
  name                          = "proxy-node-03-ip"
  preserved_state {
    internal_ip {
      interface_name = "nic0"
      auto_delete    = "NEVER"
      ip_address {
        address = google_compute_address.default.id
      }
    }
  }
}
# [END compute_stateful_instance_group_manager_ips_pic]
# [END compute_stateful_instance_group_manager_ips_parent_tag]
