/**
 * Copyright 2022 Google LLC
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

# [START vpc_packet_mirror_network]
resource "google_compute_network" "network" {
  name                    = "my-network"
  auto_create_subnetworks = false
}
# [END vpc_packet_mirror_network]

# [START vpc_packet_mirror_subnet]
resource "google_compute_subnetwork" "default" {
  name          = "my-subnet"
  ip_cidr_range = "10.124.0.0/28"
  network       = google_compute_network.network.id
  region        = "us-central1"
}
# [END vpc_packet_mirror_subnet]

# [START compute_vm_packet_mirror_vm_instance]
resource "google_compute_instance" "mirror" {
  zone         = "us-central1-a"
  name         = "my-instance"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.network.id
    subnetwork = google_compute_subnetwork.default.self_link
  }
}
# [END compute_vm_packet_mirror_vm_instance]

# [START cloudloadbalancing_vm_packet_mirror_health_check]
resource "google_compute_health_check" "default" {
  name               = "my-healthcheck"
  check_interval_sec = 1
  timeout_sec        = 1
  tcp_health_check {
    port = "80"
  }
}
# [END cloudloadbalancing_vm_packet_mirror_health_check]

# [START cloudloadbalancing_vm_packet_mirror_backend_service]
resource "google_compute_region_backend_service" "default" {
  region        = "us-central1"
  name          = "my-service"
  health_checks = [google_compute_health_check.default.id]
}
# [END cloudloadbalancing_vm_packet_mirror_backend_service]

# [START cloudloadbalancing_vm_packet_mirror_forwarding_rule]
resource "google_compute_forwarding_rule" "default" {
  name                   = "my-ilb"
  region                 = "us-central1"
  is_mirroring_collector = true
  ip_protocol            = "TCP"
  load_balancing_scheme  = "INTERNAL"
  backend_service        = google_compute_region_backend_service.default.id
  all_ports              = true
  network                = google_compute_network.network.id
  subnetwork             = google_compute_subnetwork.default.self_link
  network_tier           = "PREMIUM"
}
# [END cloudloadbalancing_vm_packet_mirror_forwarding_rule]

# [START compute_vm_packet_mirror]
resource "google_compute_packet_mirroring" "default" {
  region      = "us-central1"
  name        = "my-mirroring"
  description = "My packet mirror"
  network {
    url = google_compute_network.network.self_link
  }
  collector_ilb {
    url = google_compute_forwarding_rule.default.self_link
  }
  mirrored_resources {
    tags = ["tag-name"]
    instances {
      url = google_compute_instance.mirror.self_link
    }
  }
  filter {
    ip_protocols = ["tcp"]
    cidr_ranges  = ["0.0.0.0/0"]
    direction    = "BOTH"
  }
}
# [END compute_vm_packet_mirror]
