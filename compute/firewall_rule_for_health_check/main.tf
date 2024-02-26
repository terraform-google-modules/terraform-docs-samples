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
 * gcloud compute firewall-rules create allow-health-check \
 *   --allow tcp:80 \
 *   --source-ranges 130.211.0.0/22,35.191.0.0/16 \
 *   --network default
 */


# [START compute_firewall_rule_for_health_check_tag]
resource "google_compute_firewall" "default" {
  name          = "allow-health-check"
  network       = "default"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}
# [END compute_firewall_rule_for_health_check_tag]

