/**
 * Copyright 2026 Google LLC
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

# [START compute_ha_controller_backend_service_parent_tag]
terraform {
  required_providers {
    google-nightly = {
      source  = "hashicorp/google-nightly"
      version = "2026.10.26-8.8.1"
    }
  }
}

provider "google-nightly" {
  compute_custom_endpoint = "https://compute.googleapis.com/compute/beta/"
}

data "google_compute_image" "debian_13" {
  family  = "debian-13"
  project = "debian-cloud"
}

resource "google_compute_region_disk" "regional_disk" {
  name                      = "hac-rbs-disk"
  type                      = "pd-balanced"
  region                    = "us-central1"
  physical_block_size_bytes = 4096
  size                      = 10
  replica_zones             = ["us-central1-a", "us-central1-b"]
  image                     = data.google_compute_image.debian_13.self_link
}

resource "google_compute_instance" "vm" {
  provider     = google-nightly
  name         = "hac-rbs-vm"
  machine_type = "e2-micro"

  zones {
    zone = "us-central1-a"
  }

  zones {
    zone = "us-central1-b"
  }

  boot_disk {
    auto_delete = false
    source      = google_compute_region_disk.regional_disk.self_link
  }

  network_interface {
    network = "default"
  }

  allow_stopping_for_update = true
}

resource "google_compute_region_backend_service" "backend_service" {
  provider              = google-nightly
  name                  = "hac-rbs-bs"
  region                = "us-central1"
  protocol              = "UNSPECIFIED"
  load_balancing_scheme = "INTERNAL"
  network               = "default"

  ha_policy {
    fast_ip_move = "DISABLED"
  }

  connection_draining_timeout_sec = 0
}

# [START compute_ha_controller_backend_service]
resource "google_compute_ha_controller" "ha_controller" {
  provider            = google-nightly
  name                = "hac-rbs"
  description         = "HA Controller Backend Service Example"
  region              = "us-central1"
  instance_name       = google_compute_instance.vm.name
  failover_initiation = "MANUAL_ONLY"

  zone_configuration {
    zone = "us-central1-a"
  }

  zone_configuration {
    zone = "us-central1-b"
  }

  backend_services = [google_compute_region_backend_service.backend_service.self_link]

  # To recreate the VMs, Compute Engine must delete the HA Controller first.
  lifecycle {
    replace_triggered_by = [
      google_compute_instance.vm.id
    ]
  }
}
# [END compute_ha_controller_backend_service]
# [END compute_ha_controller_backend_service_parent_tag]
