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

# [START compute_ha_controller_sole_tenancy_parent_tag]
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

resource "google_compute_node_template" "node_template1" {
  name      = "hac-st-nt1"
  region    = "us-central1"
  node_type = "n1-node-96-624"

  node_affinity_labels = {
    workload = "synthetic"
    distinct = "1"
  }
}

resource "google_compute_node_template" "node_template2" {
  name      = "hac-st-nt2"
  region    = "us-central1"
  node_type = "n1-node-96-624"

  node_affinity_labels = {
    workload = "synthetic"
    distinct = "2"
  }
}

resource "google_compute_node_group" "sole_tenant_group1" {
  name          = "hac-st-ng1"
  zone          = "us-central1-a"
  description   = "Sole-tenant node group for HA Controller test zone 1"
  initial_size  = 1
  node_template = google_compute_node_template.node_template1.id
}

resource "google_compute_node_group" "sole_tenant_group2" {
  name          = "hac-st-ng2"
  zone          = "us-central1-b"
  description   = "Sole-tenant node group for HA Controller test zone 2"
  initial_size  = 1
  node_template = google_compute_node_template.node_template2.id
}

resource "google_compute_region_disk" "regional_disk" {
  name                      = "hac-st-disk"
  type                      = "pd-balanced"
  region                    = "us-central1"
  physical_block_size_bytes = 4096
  size                      = 10
  replica_zones             = ["us-central1-a", "us-central1-b"]
  image                     = data.google_compute_image.debian_13.self_link
}

resource "google_compute_instance" "vm" {
  provider     = google-nightly
  name         = "hac-st-vm"
  machine_type = "n1-standard-1"

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

  scheduling {
    node_affinities {
      key      = "workload"
      operator = "IN"
      values   = ["synthetic"]
    }
  }

  allow_stopping_for_update = true

  depends_on = [
    google_compute_node_group.sole_tenant_group1,
    google_compute_node_group.sole_tenant_group2
  ]
}

# [START compute_ha_controller_sole_tenancy]
resource "google_compute_ha_controller" "ha_controller" {
  provider            = google-nightly
  name                = "hac-st"
  description         = "HA Controller Sole-Tenancy Example"
  region              = "us-central1"
  instance_name       = google_compute_instance.vm.name
  failover_initiation = "MANUAL_ONLY"

  zone_configuration {
    zone = "us-central1-a"
    node_affinities {
      key      = "workload"
      operator = "IN"
      values   = ["synthetic"]
    }
  }

  zone_configuration {
    zone = "us-central1-b"
    node_affinities {
      key      = "workload"
      operator = "IN"
      values   = ["synthetic"]
    }
  }

  # To recreate the VMs, Compute Engine must delete the HA Controller first.
  lifecycle {
    replace_triggered_by = [
      google_compute_instance.vm.id
    ]
  }
}
# [END compute_ha_controller_sole_tenancy]
# [END compute_ha_controller_sole_tenancy_parent_tag]
