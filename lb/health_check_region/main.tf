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

# [START cloudloadbalancing_regional_health_check]
resource "google_compute_region_health_check" "default" {
  name               = "tcp-health-check-region-west"
  timeout_sec        = 5
  check_interval_sec = 5
  tcp_health_check {
    port = "80"
  }
  region = "us-west1"
}
# [END cloudloadbalancing_regional_health_check]
