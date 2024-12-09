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

# [START vpcflowlogs_vpn_tunnel_basic]
resource "google_network_management_vpc_flow_logs_config" "vpc_flow_logs_config" {
  provider                = google-beta
  vpn_tunnel = "projects/${data.google_project.project.project_id}/regions/us-east4/vpnTunnels/${google_compute_vpn_tunnel.tunnel.name}"
  location                = "global"
  project                 = data.google_project.project.project_id
  vpc_flow_logs_config_id = "vpcflowlogs-config"
}

data "google_project" "project" {
  provider = google-beta
}

# Create a VPN Tunnel
resource "google_compute_vpn_tunnel" "tunnel" {
  provider           = google-beta
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
  provider = google-beta
  name     = "vpcflowlogs-gateway"
  network  = google_compute_network.network.id
}

resource "google_compute_network" "network" {
  provider = google-beta
  name     = "vpcflowlogs-network"
}

resource "google_compute_address" "vpn_static_ip" {
  provider = google-beta
  name     = "vpcflowlogs-vpn-static-ip"
}

resource "google_compute_forwarding_rule" "fr_esp" {
  provider    = google-beta
  name        = "vpcflowlogs-fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.gatway.id
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  provider    = google-beta
  name        = "vpcflowlogs-fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.gatway.id
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  provider    = google-beta
  name        = "vpcflowlogs-fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.gatway.id
}

resource "google_compute_route" "route" {
  provider            = google-beta
  name                = "vpcflowlogs-route"
  network             = google_compute_network.network.name
  dest_range          = "15.0.0.0/24"
  priority            = 1000
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel.id
}
# [END vpcflowlogs_vpn_tunnel_basic]
