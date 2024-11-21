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

# [START vpcflowlogs_create_vpc_flow_logs_config_over_vpn_tunnel_with_parameters]

# google_network_management_vpc_flow_logs_config.vpc_fl_config will be created
resource "google_network_management_vpc_flow_logs_config" "vpc_fl_config" {
  aggregation_interval    = "INTERVAL_10_MIN"
  description             = "VPC Flow Logs over a VPN Gateway."
  flow_sampling           = 0.7
  location                = "global"
  metadata                = "INCLUDE_ALL_METADATA"
  project                 = "example_project"
  provider                = google-beta
  state                   = "ENABLED"
  vpc_flow_logs_config_id = "example-config-id"
  vpn_tunnel              = "projects/example_project/regions/us-central1/vpnTunnels/example_vpn_tunnel"
}
# [END vpcflowlogs_create_vpc_flow_logs_config_over_vpn_tunnel_with_parameters]
