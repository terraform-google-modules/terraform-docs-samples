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

# [START dns_managed_zone_private_peering]
resource "random_id" "zone_suffix" {
  byte_length = 8
}

resource "google_dns_managed_zone" "peering_zone" {
  name        = "peering-zone-${random_id.zone_suffix.hex}"
  dns_name    = "peering.example.com."
  description = "Example private DNS peering zone"

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.network_source.id
    }
  }

  peering_config {
    target_network {
      network_url = google_compute_network.network_target.id
    }
  }
}

resource "google_compute_network" "network_source" {
  name                    = "network-source"
  auto_create_subnetworks = false
}

resource "google_compute_network" "network_target" {
  name                    = "network-target"
  auto_create_subnetworks = false
}
# [END dns_managed_zone_private_peering]
