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
 * gcloud compute health-checks create http example-check --port 80 \
 *  --check-interval 30s \
 *  --healthy-threshold 1 \
 *  --timeout 10s \
 *  --unhealthy-threshold 3 \
 *  --global
 */

# [START compute_health_check_tag]
resource "google_compute_http_health_check" "default" {
  name                = "example-check"
  timeout_sec         = 10
  check_interval_sec  = 30
  healthy_threshold   = 1
  unhealthy_threshold = 3
  port                = "80"
}
# [END compute_health_check_tag]
