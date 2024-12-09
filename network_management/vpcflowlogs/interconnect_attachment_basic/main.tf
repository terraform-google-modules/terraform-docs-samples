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

# [START vpcflowlogs_interconnect_attachment_basic]
resource "google_network_management_vpc_flow_logs_config" "vpc_flow_logs_config" {
  provider                = google-beta
  interconnect_attachment = "projects/${data.google_project.project.project_id}/regions/us-east4/interconnectAttachments/${google_compute_interconnect_attachment.attachment.name}"
  location                = "global"
  project                 = data.google_project.project.project_id
  vpc_flow_logs_config_id = "vpcflowlogs-config"
}

data "google_project" "project" {
  provider = google-beta
}

#Create an Interconnect Attachment
resource "google_compute_network" "network" {
  provider = google-beta
  name     = "vpcflowlogs-network"
}

resource "google_compute_router" "router" {
  provider = google-beta
  name     = "vpcflowlogs-router"
  network  = google_compute_network.network.name
  bgp {
    asn = 16550
  }
}

resource "google_compute_interconnect_attachment" "attachment" {
  provider                 = google-beta
  name                     = "vpcflowlogs-attachment"
  project                  = data.google_project.project.project_id
  router                   = google_compute_router.router.id
  edge_availability_domain = "AVAILABILITY_DOMAIN_1"
  type                     = "PARTNER"
  mtu                      = 1500
}
# [END vpcflowlogs_interconnect_attachment_basic]
