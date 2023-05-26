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

# Shared VPC Internal HTTP load balancer with a managed instance group backend

# [START cloudloadbalancing_shared_vpc_http_ilb_with_mig_backend_parent_tag]
# [START cloudloadbalancing_shared_vpc_http_ilb_example]
# [START cloudloadbalancing_shared_vpc_http_ilb_network]
# VPC network
resource "google_compute_network" "default" {
  name                    = "l7-ilb-network"
  auto_create_subnetworks = false
  project                 = "my-host-project"
}
# [END cloudloadbalancing_shared_vpc_http_ilb_network]

# [START cloudloadbalancing_shared_vpc_http_ilb_proxy_subnet]
# proxy-only subnet
# https://cloud.google.com/load-balancing/docs/proxy-only-subnets#proxy_only_subnet_create
resource "google_compute_subnetwork" "proxy_subnet" {
  name          = "l7-ilb-proxy-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = google_compute_network.default.id
  project       = "my-host-project"
}
# [END cloudloadbalancing_shared_vpc_http_ilb_proxy_subnet]

# [START cloudloadbalancing_shared_vpc_http_ilb_ilb_subnet]
# backend subnet
resource "google_compute_subnetwork" "ilb_subnet" {
  name          = "l7-ilb-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.default.id
  project       = "my-host-project"
}
# [END cloudloadbalancing_shared_vpc_http_ilb_ilb_subnet]

# [START cloudloadbalancing_shared_vpc_http_ilb_fw_iap]
# allow all access from IAP and health check ranges
resource "google_compute_firewall" "fw_iap" {
  project       = "my-host-project"
  name          = "l7-ilb-fw-allow-iap-hc"
  direction     = "INGRESS"
  network       = google_compute_network.default.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20"]
  allow {
    protocol = "tcp"
  }
}
# [END cloudloadbalancing_shared_vpc_http_ilb_fw_iap]

# [START cloudloadbalancing_shared_vpc_http_ilb_fw_ilb_to_backends]
# allow http from proxy subnet to backends
resource "google_compute_firewall" "fw_ilb_to_backends" {
  project       = "my-host-project"
  name          = "l7-ilb-fw-allow-ilb-to-backends"
  direction     = "INGRESS"
  network       = google_compute_network.default.id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }
}
# [END cloudloadbalancing_shared_vpc_http_ilb_fw_ilb_to_backends]

# [START cloudloadbalancing_shared_vpc_http_ilb_forwarding_rule]
# forwarding rule
resource "google_compute_forwarding_rule" "default" {
  name                  = "l7-ilb-forwarding-rule"
  region                = "us-central1"
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.default.id
  network               = google_compute_network.default.id
  subnetwork            = google_compute_subnetwork.ilb_subnet.id
  network_tier          = "PREMIUM"
  project               = "my-service-project-01"
  depends_on            = [google_compute_subnetwork.proxy_subnet]
}
# [END cloudloadbalancing_shared_vpc_http_ilb_forwarding_rule]

# [START cloudloadbalancing_shared_vpc_http_ilb_regional_http_proxy]
# HTTP target proxy
resource "google_compute_region_target_http_proxy" "default" {
  name    = "l7-ilb-target-http-proxy"
  region  = "us-central1"
  url_map = google_compute_region_url_map.default.id
  project = "my-service-project-01"
}
# [END cloudloadbalancing_shared_vpc_http_ilb_regional_http_proxy]

# [START cloudloadbalancing_shared_vpc_http_ilb_url_map]
# URL map
resource "google_compute_region_url_map" "default" {
  name            = "l7-ilb-regional-url-map"
  region          = "us-central1"
  default_service = google_compute_region_backend_service.default.id
  project         = "my-service-project-01"
}
# [END cloudloadbalancing_shared_vpc_http_ilb_url_map]

# [START cloudloadbalancing_shared_vpc_http_ilb_regional_hc]
# regional health check
resource "google_compute_region_health_check" "default" {
  project = "my-service-project-02"
  name    = "l7-ilb-rhc"
  region  = "us-central1"
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}
# [END cloudloadbalancing_shared_vpc_http_ilb_regional_hc]

# [START cloudloadbalancing_shared_vpc_http_ilb_regional_backend]
# regional backend service
resource "google_compute_region_backend_service" "default" {
  project               = "my-service-project-02"
  name                  = "l7-ilb-backend-service"
  region                = "us-central1"
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  timeout_sec           = 10
  health_checks         = [google_compute_region_health_check.default.id]
  backend {
    group           = google_compute_region_instance_group_manager.default.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}
# [END cloudloadbalancing_shared_vpc_http_ilb_regional_backend]

# [START cloudloadbalancing_shared_vpc_http_ilb_hc]
# health check
resource "google_compute_health_check" "default" {
  project            = "my-service-project-02"
  name               = "l7-ilb-hc"
  timeout_sec        = 1
  check_interval_sec = 1
  tcp_health_check {
    port = "80"
  }
}
# [END cloudloadbalancing_shared_vpc_http_ilb_hc]

# [START cloudloadbalancing_shared_vpc_http_ilb_instance_template]
# instance template
resource "google_compute_instance_template" "default" {
  project      = "my-service-project-02"
  name         = "l7-ilb-mig-template"
  machine_type = "e2-small"
  tags         = ["http-server"]

  network_interface {
    network    = google_compute_network.default.id
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
}
# [END cloudloadbalancing_shared_vpc_http_ilb_instance_template]

# [START cloudloadbalancing_shared_vpc_http_ilb_mig]
# MIG
resource "google_compute_region_instance_group_manager" "default" {
  project = "my-service-project-02"
  name    = "l7-ilb-mig1"
  region  = "us-central1"
  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 2
  auto_healing_policies {
    health_check      = google_compute_health_check.default.id
    initial_delay_sec = 300
  }
  depends_on = [google_project_iam_binding.default]
}
# [END cloudloadbalancing_shared_vpc_http_ilb_mig]

# [START cloudloadbalancing_shared_vpc_http_ilb_iam_binding]
data "google_project" "service_project02" {
  project_id = "my-service-project-02"
}

# IAM Role
resource "google_project_iam_binding" "default" {
  project = "my-host-project"
  role    = "roles/compute.networkUser"

  members = [
    "serviceAccount:${data.google_project.service_project02.number}@cloudservices.gserviceaccount.com",
  ]
}
# [END cloudloadbalancing_shared_vpc_http_ilb_iam_binding]

# [START cloudloadbalancing_shared_vpc_http_ilb_test_instance]
# test instance
resource "google_compute_instance" "test_vm" {
  project      = "my-service-project-02"
  name         = "l7-ilb-test-vm"
  zone         = "us-central1-b"
  machine_type = "e2-small"
  network_interface {
    network    = google_compute_network.default.id
    subnetwork = google_compute_subnetwork.ilb_subnet.id
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  lifecycle {
    ignore_changes = [
      metadata["ssh-keys"]
    ]
  }
  depends_on = [google_project_iam_binding.default]
}
# [END cloudloadbalancing_shared_vpc_http_ilb_test_instance]
# [END cloudloadbalancing_shared_vpc_http_ilb_example]
# [END cloudloadbalancing_shared_vpc_http_ilb_with_mig_backend_parent_tag]