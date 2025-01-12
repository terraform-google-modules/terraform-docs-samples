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

# [START vpcflowlogs_vpn_tunnel_full_parent_tag]
# [START vpcflowlogs_vpn_tunnel_full_vpcflow]
resource "google_network_management_vpc_flow_logs_config" "vpc_flow_logs_config" {
  vpc_flow_logs_config_id = "vpcflowlogs-config"
  location                = "global"
  vpn_tunnel              = google_compute_vpn_tunnel.tunnel.id
  aggregation_interval    = "INTERVAL_10_MIN"
  description             = "VPC Flow Logs over a VPN Gateway."
  flow_sampling           = 0.7
  metadata                = "INCLUDE_ALL_METADATA"
  state                   = "ENABLED"
}
# [END vpcflowlogs_vpn_tunnel_full_vpcflow]

# [START vpcflowlogs_vpn_tunnel_full_network]
resource "google_compute_vpn_tunnel" "tunnel" {
  name               = "vpcflowlogs-tunnel"
  peer_ip            = "15.0.0.120"
  shared_secret      = "a secret message"
  target_vpn_gateway = google_compute_vpn_gateway.gatway.id

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
  ]
}

resource "google_compute_vpn_gateway" "gatway" {
  name    = "vpcflowlogs-gateway"
  network = google_compute_network.network.id
}

resource "google_compute_network" "network" {
  name = "vpcflowlogs-network"
}

resource "google_compute_address" "vpn_static_ip" {
  name = "vpcflowlogs-vpn-static-ip"
}

resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "vpcflowlogs-fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.gatway.id
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "vpcflowlogs-fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.gatway.id
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "vpcflowlogs-fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.gatway.id
}

resource "google_compute_route" "route" {
  name                = "vpcflowlogs-route"
  network             = google_compute_network.network.name
  dest_range          = "15.0.0.0/24"
  priority            = 1000
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel.id
}
# [END vpcflowlogs_vpn_tunnel_full_network]
# [END vpcflowlogs_vpn_tunnel_full_parent_tag]
