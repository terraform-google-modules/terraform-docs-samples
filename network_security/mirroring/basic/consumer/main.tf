/**
* Copyright 2025 Google LLC
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

# [START networksecurity_mirroring_basic_consumer]
# [START networksecurity_mirroring_create_producer_network_tf]
resource "google_compute_network" "producer_network" {
  name                    = "producer-network"
  auto_create_subnetworks = false
}
# [END networksecurity_mirroring_create_producer_network_tf]

# [START networksecurity_mirroring_create_consumer_network_tf]
resource "google_compute_network" "consumer_network" {
  name                    = "consumer-network"
  auto_create_subnetworks = false
}
# [END networksecurity_mirroring_create_consumer_network_tf]

# [START networksecurity_mirroring_create_producer_deployment_group_tf]
resource "google_network_security_mirroring_deployment_group" "default" {
  mirroring_deployment_group_id = "mirroring-deployment-group"
  location                      = "global"
  network                       = google_compute_network.producer_network.id
}
# [END networksecurity_mirroring_create_producer_deployment_group_tf]

# [START networksecurity_mirroring_create_endpoint_group_tf]
resource "google_network_security_mirroring_endpoint_group" "default" {
  mirroring_endpoint_group_id = "mirroring-endpoint-group"
  location                    = "global"
  mirroring_deployment_group  = google_network_security_mirroring_deployment_group.default.id
}
# [END networksecurity_mirroring_create_endpoint_group_tf]

# [START networksecurity_mirroring_create_endpoint_group_association_tf]
resource "google_network_security_mirroring_endpoint_group_association" "default" {
  mirroring_endpoint_group_association_id = "mirroring-endpoint-group-association"
  location                                = "global"
  network                                 = google_compute_network.consumer_network.id
  mirroring_endpoint_group                = google_network_security_mirroring_endpoint_group.default.id
}
# [END networksecurity_mirroring_create_endpoint_group_association_tf]
# [END networksecurity_mirroring_basic_consumer]
