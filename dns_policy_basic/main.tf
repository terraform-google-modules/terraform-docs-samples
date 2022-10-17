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

# [START dns_policy_basic]
resource "google_dns_policy" "example_policy" {
  name                      = "example-policy"
  enable_inbound_forwarding = true

  enable_logging = true

  alternative_name_server_config {
    target_name_servers {
      ipv4_address    = "172.16.1.10"
      forwarding_path = "private"
    }
    target_name_servers {
      ipv4_address = "172.16.1.20"
    }
  }

  networks {
    network_url = google_compute_network.network_1.id
  }
  networks {
    network_url = google_compute_network.network_2.id
  }
}

resource "google_compute_network" "network_1" {
  name                    = "network-1"
  auto_create_subnetworks = false
}

resource "google_compute_network" "network_2" {
  name                    = "network-2"
  auto_create_subnetworks = false
}
# [END dns_policy_basic]
