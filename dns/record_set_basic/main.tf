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

# [START dns_record_set_basic]
resource "google_dns_managed_zone" "parent_zone" {
  name        = "sample-zone"
  dns_name    = "sample-zone.hashicorptest.com."
  description = "Test Description"
}

resource "google_dns_record_set" "default" {
  managed_zone = google_dns_managed_zone.parent_zone.name
  name         = "test-record.sample-zone.hashicorptest.com."
  type         = "A"
  rrdatas      = ["10.0.0.1", "10.1.0.1"]
  ttl          = 86400
}
# [END dns_record_set_basic]
