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

data "google_project" "default" {}

# In case the project is in a folder, extract the organization ID from it.
data "google_folder" "default" {
  count               = data.google_project.default.folder_id != "" ? 1 : 0
  folder              = data.google_project.default.folder_id
  lookup_organization = true
}

data "google_organization" "default" {
  organization = data.google_project.default.org_id != "" ? data.google_project.default.org_id : data.google_folder.default[0].organization
}

# [START networksecurity_intercept_basic_consumer]
# [START networksecurity_intercept_create_producer_network_tf]
resource "google_compute_network" "producer_network" {
  name                    = "producer-network"
  auto_create_subnetworks = false
}
# [END networksecurity_intercept_create_producer_network_tf]

# [START networksecurity_intercept_create_consumer_network_tf]
resource "google_compute_network" "consumer_network" {
  name                    = "consumer-network"
  auto_create_subnetworks = false
}
# [END networksecurity_intercept_create_consumer_network_tf]

# [START networksecurity_intercept_create_consumer_subnetwork_tf]
resource "google_compute_subnetwork" "consumer_subnet" {
  name          = "consumer-subnet"
  region        = "us-central1"
  ip_cidr_range = "10.10.0.0/16"
  network       = google_compute_network.consumer_network.name
}
# [END networksecurity_intercept_create_consumer_subnetwork_tf]

# [START networksecurity_intercept_create_producer_deployment_group_tf]
resource "google_network_security_intercept_deployment_group" "default" {
  intercept_deployment_group_id = "intercept-deployment-group"
  location                      = "global"
  network                       = google_compute_network.producer_network.id
}
# [END networksecurity_intercept_create_producer_deployment_group_tf]

# [START networksecurity_intercept_create_endpoint_group_tf]
resource "google_network_security_intercept_endpoint_group" "default" {
  intercept_endpoint_group_id = "intercept-endpoint-group"
  location                    = "global"
  intercept_deployment_group  = google_network_security_intercept_deployment_group.default.id
}
# [END networksecurity_intercept_create_endpoint_group_tf]

# [START networksecurity_intercept_create_endpoint_group_association_tf]
resource "google_network_security_intercept_endpoint_group_association" "default" {
  intercept_endpoint_group_association_id = "intercept-endpoint-group-association"
  location                                = "global"
  network                                 = google_compute_network.consumer_network.id
  intercept_endpoint_group                = google_network_security_intercept_endpoint_group.default.id
}
# [END networksecurity_intercept_create_endpoint_group_association_tf]

# [START networksecurity_intercept_create_security_profile_tf]
resource "google_network_security_security_profile" "default" {
  name     = "security-profile"
  type     = "CUSTOM_INTERCEPT"
  parent   = "organizations/${data.google_organization.default.org_id}"
  location = "global"

  custom_intercept_profile {
    intercept_endpoint_group = google_network_security_intercept_endpoint_group.default.id
  }
}
# [END networksecurity_intercept_create_security_profile_tf]

# [START networksecurity_intercept_create_security_profile_group_tf]
resource "google_network_security_security_profile_group" "default" {
  name                     = "security-profile-group"
  parent                   = "organizations/${data.google_organization.default.org_id}"
  location                 = "global"
  custom_intercept_profile = google_network_security_security_profile.default.id
}
# [END networksecurity_intercept_create_security_profile_group_tf]

# [START networksecurity_intercept_create_firewall_policy_tf]
resource "google_compute_network_firewall_policy" "default" {
  name = "firewall-policy"
}
# [END networksecurity_intercept_create_firewall_policy_tf]

# [START networksecurity_intercept_create_firewall_policy_rule_tf]
resource "google_compute_network_firewall_policy_rule" "default" {
  firewall_policy        = google_compute_network_firewall_policy.default.name
  priority               = 1000
  action                 = "apply_security_profile_group"
  direction              = "INGRESS"
  security_profile_group = google_network_security_security_profile_group.default.id

  match {
    layer4_configs {
      ip_protocol = "tcp"
      ports       = ["80"]
    }
    src_ip_ranges = ["10.10.0.0/16"]
  }
}
# [END networksecurity_intercept_create_firewall_policy_rule_tf]

# [START networksecurity_intercept_create_firewall_policy_association_tf]
resource "google_compute_network_firewall_policy_association" "default" {
  name              = "firewall-policy-assoc"
  attachment_target = google_compute_network.consumer_network.id
  firewall_policy   = google_compute_network_firewall_policy.default.name
}
# [END networksecurity_intercept_create_firewall_policy_association_tf]
# [END networksecurity_intercept_basic_consumer]
