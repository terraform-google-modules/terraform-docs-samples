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

# [START compute_ha_controller_multi_nic_static_ip_parent_tag]
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

resource "google_compute_network" "network_0" {
  name                    = "hac-sip-net0"
  auto_create_subnetworks = false
}

resource "google_compute_network" "network_1" {
  name                    = "hac-sip-net1"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_0" {
  name          = "hac-sip-sub0"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.network_0.id
}

resource "google_compute_subnetwork" "subnet_1" {
  name          = "hac-sip-sub1"
  ip_cidr_range = "10.0.2.0/24"
  region        = "us-central1"
  network       = google_compute_network.network_1.id
}

resource "google_compute_address" "ipv4_nic0_zone1" {
  name         = "hac-sip-ip-nic0-z1"
  subnetwork   = google_compute_subnetwork.subnet_0.id
  address_type = "INTERNAL"
  address      = "10.0.1.10"
  region       = "us-central1"
}

resource "google_compute_address" "ipv4_nic0_zone2" {
  name         = "hac-sip-ip-nic0-z2"
  subnetwork   = google_compute_subnetwork.subnet_0.id
  address_type = "INTERNAL"
  address      = "10.0.1.11"
  region       = "us-central1"
}

resource "google_compute_address" "ipv4_nic1_zone1" {
  name         = "hac-sip-ip-nic1-z1"
  subnetwork   = google_compute_subnetwork.subnet_1.id
  address_type = "INTERNAL"
  address      = "10.0.2.10"
  region       = "us-central1"
}

resource "google_compute_address" "ipv4_nic1_zone2" {
  name         = "hac-sip-ip-nic1-z2"
  subnetwork   = google_compute_subnetwork.subnet_1.id
  address_type = "INTERNAL"
  address      = "10.0.2.11"
  region       = "us-central1"
}

data "google_compute_image" "debian_13" {
  family  = "debian-13"
  project = "debian-cloud"
}

resource "google_compute_region_disk" "regional_disk" {
  name                      = "hac-sip-disk"
  type                      = "pd-balanced"
  region                    = "us-central1"
  physical_block_size_bytes = 4096
  size                      = 10
  replica_zones             = ["us-central1-a", "us-central1-b"]
  image                     = data.google_compute_image.debian_13.self_link
}

resource "google_compute_instance" "vm" {
  provider     = google-nightly
  name         = "hac-sip-vm"
  machine_type = "e2-micro"

  zones {
    zone = "us-central1-a"

    network_interface {
      name       = "nic0"
      network_ip = google_compute_address.ipv4_nic0_zone1.address
    }

    network_interface {
      name       = "nic1"
      network_ip = google_compute_address.ipv4_nic1_zone1.address
    }
  }

  zones {
    zone = "us-central1-b"

    network_interface {
      name       = "nic0"
      network_ip = google_compute_address.ipv4_nic0_zone2.address
    }

    network_interface {
      name       = "nic1"
      network_ip = google_compute_address.ipv4_nic1_zone2.address
    }
  }

  boot_disk {
    auto_delete = false
    source      = google_compute_region_disk.regional_disk.self_link
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_0.id
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_1.id
  }

  allow_stopping_for_update = true
}

# [START compute_ha_controller_multi_nic_static_ip]
resource "google_compute_ha_controller" "ha_controller" {
  provider            = google-nightly
  name                = "hac-sip"
  description         = "HA Controller Multi-NIC Static IP Example"
  region              = "us-central1"
  instance_name       = google_compute_instance.vm.name
  failover_initiation = "MANUAL_ONLY"

  zone_configuration {
    zone = "us-central1-a"

    instance_network_interface {
      name       = "nic0"
      network_ip = google_compute_address.ipv4_nic0_zone1.address
    }

    instance_network_interface {
      name       = "nic1"
      network_ip = google_compute_address.ipv4_nic1_zone1.address
    }
  }

  zone_configuration {
    zone = "us-central1-b"

    instance_network_interface {
      name       = "nic0"
      network_ip = google_compute_address.ipv4_nic0_zone2.address
    }

    instance_network_interface {
      name       = "nic1"
      network_ip = google_compute_address.ipv4_nic1_zone2.address
    }
  }

  # To recreate the VMs, Compute Engine must delete the HA Controller first.
  lifecycle {
    replace_triggered_by = [
      google_compute_instance.vm.id
    ]
  }
}
# [END compute_ha_controller_multi_nic_static_ip]
# [END compute_ha_controller_multi_nic_static_ip_parent_tag]
