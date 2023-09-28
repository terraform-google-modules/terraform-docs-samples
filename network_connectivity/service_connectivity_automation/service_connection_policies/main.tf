/**
 * Copyright 2023 Google LLC
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

# [START networkconnectivity_create_service_connection_policy]
# Create a VPC network
resource "google_compute_network" "default" {
  name                    = "consumer-network"
  auto_create_subnetworks = false
}

# Create a subnetwork
resource "google_compute_subnetwork" "default" {
  name          = "consumer-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.default.id
}

# Create a service connection policy
resource "google_network_connectivity_service_connection_policy" "default" {
  name          = "service-connection-policy"
  location      = "us-central1"
  service_class = "gcp-memorystore-redis"
  network       = google_compute_network.default.id
  psc_config {
    subnetworks = [google_compute_subnetwork.default.id]
    limit       = 2
  }
}
# [END networkconnectivity_create_service_connection_policy]

