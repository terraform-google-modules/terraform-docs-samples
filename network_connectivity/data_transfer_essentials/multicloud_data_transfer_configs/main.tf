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

# [START datatransferessentials_multicloud_data_transfer_config]
resource "google_network_connectivity_multicloud_data_transfer_config" "default" {
  name        = "config"
  location    = "europe-west1"
  description = "A basic multicloud data transfer config"
  services {
    service_name = "big-query"
  }
  services {
    service_name = "cloud-storage"
  }
}
# [END datatransferessentials_multicloud_data_transfer_config]
