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

# [START networksecurity_intercept_basic_producer]
# [START networksecurity_intercept_create_network_tf]
resource "google_compute_network" "default" {
  provider                = google-beta
  name                    = "producer-network"
  auto_create_subnetworks = false
}
# [END networksecurity_intercept_create_network_tf]

# [START networksecurity_intercept_create_subnetwork_tf]
resource "google_compute_subnetwork" "default" {
  provider      = google-beta
  name          = "producer-subnet"
  region        = "us-central1"
  ip_cidr_range = "10.1.0.0/16"
  network       = google_compute_network.default.name
}
# [END networksecurity_intercept_create_subnetwork_tf]

# [START networksecurity_intercept_create_health_check_tf]
resource "google_compute_region_health_check" "default" {
  provider = google-beta
  name     = "deploymnet-hc"
  region   = "us-central1"
  http_health_check {
    port = 80
  }
}
# [END networksecurity_intercept_create_health_check_tf]

# [START networksecurity_intercept_create_backend_service_tf]
resource "google_compute_region_backend_service" "default" {
  provider              = google-beta
  name                  = "deployment-svc"
  region                = "us-central1"
  health_checks         = [google_compute_region_health_check.default.id]
  protocol              = "UDP"
  load_balancing_scheme = "INTERNAL"
}
# [END networksecurity_intercept_create_backend_service_tf]

# [START networksecurity_intercept_create_forwarding_rule_tf]
resource "google_compute_forwarding_rule" "default" {
  provider              = google-beta
  name                  = "deployment-fr"
  region                = "us-central1"
  network               = google_compute_network.default.name
  subnetwork            = google_compute_subnetwork.default.name
  backend_service       = google_compute_region_backend_service.default.id
  load_balancing_scheme = "INTERNAL"
  ports                 = [6081]
  ip_protocol           = "UDP"
}
# [END networksecurity_intercept_create_forwarding_rule_tf]

# [START networksecurity_intercept_create_deployment_group_tf]
resource "google_network_security_intercept_deployment_group" "default" {
  provider                      = google-beta
  intercept_deployment_group_id = "intercept-deployment-group"
  location                      = "global"
  network                       = google_compute_network.default.id
}
# [END networksecurity_intercept_create_deployment_group_tf]

# [START networksecurity_intercept_create_deployment_tf]
resource "google_network_security_intercept_deployment" "default" {
  provider                   = google-beta
  intercept_deployment_id    = "intercept-deployment"
  location                   = "us-central1-a"
  forwarding_rule            = google_compute_forwarding_rule.default.id
  intercept_deployment_group = google_network_security_intercept_deployment_group.default.id
}
# [END networksecurity_intercept_create_deployment_tf]
# [END networksecurity_intercept_basic_producer]
