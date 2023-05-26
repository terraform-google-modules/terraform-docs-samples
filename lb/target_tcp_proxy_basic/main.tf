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

# [START cloudloadbalancing_target_tcp_proxy_basic_parent_tag]
# [START cloudloadbalancing_target_tcp_proxy_basic]
resource "google_compute_target_tcp_proxy" "default" {
  name            = "test-proxy"
  backend_service = google_compute_backend_service.default.id
}

resource "google_compute_backend_service" "default" {
  name        = "backend-service"
  protocol    = "TCP"
  timeout_sec = 10

  health_checks = [google_compute_health_check.default.id]
}

resource "google_compute_health_check" "default" {
  name               = "health-check"
  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = "443"
  }
}
# [END cloudloadbalancing_target_tcp_proxy_basic]
# [END cloudloadbalancing_target_tcp_proxy_basic_parent_tag]