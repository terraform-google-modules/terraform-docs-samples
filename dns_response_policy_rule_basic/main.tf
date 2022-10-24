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

# [START dns_response_policy_rule_basic]
resource "google_compute_network" "network_1" {
  provider = google-beta

  name                    = "network-1"
  auto_create_subnetworks = false
}

resource "google_compute_network" "network_2" {
  provider = google-beta

  name                    = "network-2"
  auto_create_subnetworks = false
}

resource "google_dns_response_policy" "response_policy" {
  provider = google-beta

  response_policy_name = "example-response-policy"

  networks {
    network_url = google_compute_network.network_1.id
  }
  networks {
    network_url = google_compute_network.network_2.id
  }
}

resource "google_dns_response_policy_rule" "example_response_policy_rule" {
  provider = google-beta

  response_policy = google_dns_response_policy.response_policy.response_policy_name
  rule_name       = "example-rule"
  dns_name        = "dns.example.com."

  local_data {
    local_datas {
      name    = "dns.example.com."
      type    = "A"
      ttl     = 300
      rrdatas = ["192.0.2.91"]
    }
  }

}
# [END dns_response_policy_rule_basic]
