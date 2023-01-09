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

# Internal TCP/UDP load balancer with a managed instance group backend

# [START cloudloadbalancing_int_tcp_udp_gce]

# [START vpc_int_tcp_udp_gce_network]
resource "google_compute_network" "ilb_network" {
  name                    = "l4-ilb-network"
  auto_create_subnetworks = false
}
# [END vpc_int_tcp_udp_gce_network]

# [START vpc_int_tcp_udp_gce_subnet] 
resource "google_compute_subnetwork" "ilb_subnet" {
  name          = "l4-ilb-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-west1"
  network       = google_compute_network.ilb_network.id
}
# [END vpc_int_tcp_udp_gce_subnet]

# [START cloudloadbalancing_int_tcp_udp_gce_forwarding_rule]
resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
  name                  = "l4-ilb-forwarding-rule"
  backend_service       = google_compute_region_backend_service.default.id
  region                = "europe-west1"
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL"
  all_ports             = true
  allow_global_access   = true
  network               = google_compute_network.ilb_network.id
  subnetwork            = google_compute_subnetwork.ilb_subnet.id
}
# [END cloudloadbalancing_int_tcp_udp_gce_forwarding_rule]

# [START cloudloadbalancing_int_tcp_udp_gce_backend_service]
resource "google_compute_region_backend_service" "default" {
  name                  = "l4-ilb-backend-subnet"
  region                = "europe-west1"
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_region_health_check.default.id]
  backend {
    group          = google_compute_region_instance_group_manager.mig.instance_group
    balancing_mode = "CONNECTION"
  }
}
# [END cloudloadbalancing_int_tcp_udp_gce_backend_service]

# [START compute_int_tcp_udp_gce_instance_template]
resource "google_compute_instance_template" "instance_template" {
  name         = "l4-ilb-mig-template"
  machine_type = "e2-small"
  tags         = ["allow-ssh", "allow-health-check"]

  network_interface {
    network    = google_compute_network.ilb_network.id
    subnetwork = google_compute_subnetwork.ilb_subnet.id
    access_config {
      # add external ip to fetch packages
    }
  }
  disk {
    source_image = "debian-cloud/debian-10"
    auto_delete  = true
    boot         = true
  }

  # install nginx and serve a simple web page
  metadata = {
    startup-script = <<-EOF1
      #! /bin/bash
      set -euo pipefail

      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y nginx-light jq

      NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
      IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
      METADATA=$(curl -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" | jq 'del(.["startup-script"])')

      cat <<EOF > /var/www/html/index.html
      <pre>
      Name: $NAME
      IP: $IP
      Metadata: $METADATA
      </pre>
      EOF
    EOF1
  }
  lifecycle {
    create_before_destroy = true
  }
}
# [END compute_int_tcp_udp_gce_instance_template]

# [START cloudloadbalancing_int_tcp_udp_gce_health_check]
resource "google_compute_region_health_check" "default" {
  name   = "l4-ilb-hc"
  region = "europe-west1"
  http_health_check {
    port = "80"
  }
}
# [END cloudloadbalancing_int_tcp_udp_gce_health_check]

# [START compute_int_tcp_udp_gce_mig]
resource "google_compute_region_instance_group_manager" "mig" {
  name   = "l4-ilb-mig1"
  region = "europe-west1"
  version {
    instance_template = google_compute_instance_template.instance_template.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 2
}
# [END compute_int_tcp_udp_gce_mig]

# [START vpc_int_tcp_udp_gce_mig_firewall_health_check]
# allow all access from health check ranges
resource "google_compute_firewall" "fw_hc" {
  name          = "l4-ilb-fw-allow-hc"
  direction     = "INGRESS"
  network       = google_compute_network.ilb_network.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20"]
  allow {
    protocol = "tcp"
  }
  target_tags = ["allow-health-check"]
}
# [END vpc_int_tcp_udp_gce_mig_firewall_health_check]

# [START vpc_int_tcp_udp_gce_firewall_backends]
# allow communication within the subnet
resource "google_compute_firewall" "fw_ilb_to_backends" {
  name          = "l4-ilb-fw-allow-ilb-to-backends"
  direction     = "INGRESS"
  network       = google_compute_network.ilb_network.id
  source_ranges = ["10.0.1.0/24"]
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
}
# [END vpc_int_tcp_udp_gce_firewall_backends]

# [START vpc_int_tcp_udp_gce_firewall_ssh]
# allow SSH
resource "google_compute_firewall" "fw_ilb_ssh" {
  name      = "l4-ilb-fw-ssh"
  direction = "INGRESS"
  network   = google_compute_network.ilb_network.id
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags   = ["allow-ssh"]
  source_ranges = ["0.0.0.0/0"]
}
# [END vpc_int_tcp_udp_gce_firewall_ssh]

# [START compute_int_tcp_udp_gce_test_instance]
resource "google_compute_instance" "vm_test" {
  name         = "l4-ilb-test-vm"
  tags         = ["allow-ssh"]
  zone         = "europe-west1-b"
  machine_type = "e2-small"
  network_interface {
    network    = google_compute_network.ilb_network.id
    subnetwork = google_compute_subnetwork.ilb_subnet.id
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
}
# [END compute_int_tcp_udp_gce_test_instance]

# [END cloudloadbalancing_int_tcp_udp_gce]]
