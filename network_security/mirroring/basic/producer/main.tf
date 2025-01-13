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

# [START networksecurity_mirroring_basic_producer]
resource "google_compute_network" "network" {
  provider                = google-beta
  name                    = "producer-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnetwork" {
  provider      = google-beta
  name          = "producer-subnet"
  region        = "us-central1"
  ip_cidr_range = "10.1.0.0/16"
  network       = google_compute_network.network.name
}

resource "google_compute_region_health_check" "health_check" {
  provider = google-beta
  name     = "deploymnet-hc"
  region   = "us-central1"
  http_health_check {
    port = 80
  }
}

resource "google_compute_region_backend_service" "backend_service" {
  provider              = google-beta
  name                  = "deployment-svc"
  region                = "us-central1"
  health_checks         = [google_compute_region_health_check.health_check.id]
  protocol              = "UDP"
  load_balancing_scheme = "INTERNAL"
}

resource "google_compute_forwarding_rule" "forwarding_rule" {
  provider               = google-beta
  name                   = "deployment-fr"
  region                 = "us-central1"
  network                = google_compute_network.network.name
  subnetwork             = google_compute_subnetwork.subnetwork.name
  backend_service        = google_compute_region_backend_service.backend_service.id
  load_balancing_scheme  = "INTERNAL"
  ports                  = [6081]
  ip_protocol            = "UDP"
  is_mirroring_collector = true
}

resource "google_network_security_mirroring_deployment_group" "deployment_group" {
  provider                      = google-beta
  mirroring_deployment_group_id = "mirroring-deployment-group"
  location                      = "global"
  network                       = google_compute_network.network.id
}

resource "google_network_security_mirroring_deployment" "deployment" {
  provider                   = google-beta
  mirroring_deployment_id    = "mirroring-deployment"
  location                   = "us-central1-a"
  forwarding_rule            = google_compute_forwarding_rule.forwarding_rule.id
  mirroring_deployment_group = google_network_security_mirroring_deployment_group.deployment_group.id
}
# [END networksecurity_mirroring_basic_producer]
