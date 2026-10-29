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

# [START compute_ha_controller_reservations_parent_tag]
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

# Reservations in both zones must have the same name; otherwise, you encounter
# errors after a failover because the Terraform state no longer matches your
# configuration.
resource "google_compute_reservation" "reservation_zone1" {
  name                          = "hac-rv-rv"
  zone                          = "us-central1-a"
  specific_reservation_required = true

  reservation_sharing_policy {
    service_share_type = "DISALLOW_ALL"
  }

  specific_reservation {
    count = 1
    instance_properties {
      machine_type = "e2-micro"
    }
  }
}

resource "google_compute_reservation" "reservation_zone2" {
  name                          = "hac-rv-rv"
  zone                          = "us-central1-b"
  specific_reservation_required = true

  reservation_sharing_policy {
    service_share_type = "DISALLOW_ALL"
  }

  specific_reservation {
    count = 1
    instance_properties {
      machine_type = "e2-micro"
    }
  }
}

resource "google_compute_region_disk" "regional_disk" {
  name                      = "hac-rv-disk"
  type                      = "pd-balanced"
  region                    = "us-central1"
  physical_block_size_bytes = 4096
  size                      = 10
  replica_zones             = ["us-central1-a", "us-central1-b"]
  image                     = data.google_compute_image.debian_13.self_link
}

resource "google_compute_instance" "vm" {
  provider     = google-nightly
  name         = "hac-rv-vm"
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
    subnetwork = "default"
    stack_type = "IPV4_ONLY"
  }

  reservation_affinity {
    type = "SPECIFIC_RESERVATION"
    specific_reservation {
      key    = "compute.googleapis.com/reservation-name"
      values = [google_compute_reservation.reservation_zone1.name]
    }
  }

  allow_stopping_for_update = true
}

# [START compute_ha_controller_reservations]
resource "google_compute_ha_controller" "ha_controller" {
  provider            = google-nightly
  name                = "hac-rv"
  description         = "HA Controller Reservations Example"
  region              = "us-central1"
  instance_name       = google_compute_instance.vm.name
  failover_initiation = "MANUAL_ONLY"

  networking_auto_configuration {
    internal {
      stack_type = "IPV4_ONLY"
    }
  }

  # Reservations in both zones must have the same name; otherwise, you encounter
  # errors after a failover because the Terraform state no longer matches your
  # configuration.
  zone_configuration {
    zone = "us-central1-a"
    reservation_affinity {
      type = "SPECIFIC_RESERVATION"
      specific_reservation {
        key    = "compute.googleapis.com/reservation-name"
        values = [google_compute_reservation.reservation_zone1.name]
      }
    }
  }

  zone_configuration {
    zone = "us-central1-b"
    reservation_affinity {
      type = "SPECIFIC_RESERVATION"
      specific_reservation {
        key    = "compute.googleapis.com/reservation-name"
        values = [google_compute_reservation.reservation_zone2.name]
      }
    }
  }

  # To recreate the VMs, Compute Engine must delete the HA Controller first.
  lifecycle {
    replace_triggered_by = [
      google_compute_instance.vm.id
    ]
  }
}
# [END compute_ha_controller_reservations]
# [END compute_ha_controller_reservations_parent_tag]
