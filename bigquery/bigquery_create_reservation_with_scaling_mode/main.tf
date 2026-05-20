/**
 * Copyright 2026 Google LLC
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

# [START bigquery_create_reservation_with_scaling_mode]
resource "google_bigquery_reservation" "default" {
  provider          = google-beta
  name              = "my-reservation"
  location          = "us-central1"
  slot_capacity     = 100
  edition           = "ENTERPRISE"
  ignore_idle_slots = true
  concurrency       = 0 # Automatically adjust query concurrency based on available resources
  max_slots         = 300
  scaling_mode      = "AUTOSCALE_ONLY"
}
# [END bigquery_create_reservation_with_scaling_mode]
