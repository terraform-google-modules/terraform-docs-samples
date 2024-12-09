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
resource "google_network_management_vpc_flow_logs_config" "vpc_fl_config" {
  provider                = google-beta
  interconnect_attachment = "projects/example_project/regions/us-central1/interconnectAttachments/example_interconnect"
  location                = "global"
  project                 = "example_project"
  vpc_flow_logs_config_id = "example-config-id"
}
# [END vpcflowlogs_interconnect_attachment_basic]
