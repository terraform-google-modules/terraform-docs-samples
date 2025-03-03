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

# [START vpcflowlogs_interconnect_attachment_full_parent_tag]
# [START vpcflowlogs_interconnect_attachment_full_vpcflow]
resource "google_network_management_vpc_flow_logs_config" "vpc_flow_logs_config" {
  vpc_flow_logs_config_id = "vpcflowlogs-config"
  location                = "global"
  interconnect_attachment = google_compute_interconnect_attachment.attachment.id
  aggregation_interval    = "INTERVAL_10_MIN"
  description             = "VPC Flow Logs over an Interconnect Attachment."
  flow_sampling           = 0.7
  metadata                = "INCLUDE_ALL_METADATA"
  state                   = "ENABLED"
}
# [END vpcflowlogs_interconnect_attachment_full_vpcflow]

# [START vpcflowlogs_interconnect_attachment_full_network]
resource "google_compute_network" "network" {
  name = "vpcflowlogs-network"
}

resource "google_compute_router" "router" {
  name    = "vpcflowlogs-router"
  region  = "us-central1"
  network = google_compute_network.network.name
  bgp {
    asn = 16550
  }
}

resource "google_compute_interconnect_attachment" "attachment" {
  name                     = "vpcflowlogs-attachment"
  region                   = "us-central1"
  router                   = google_compute_router.router.id
  edge_availability_domain = "AVAILABILITY_DOMAIN_1"
  type                     = "PARTNER"
  mtu                      = 1500
}
# [END vpcflowlogs_interconnect_attachment_full_network]
# [END vpcflowlogs_interconnect_attachment_full_parent_tag]
