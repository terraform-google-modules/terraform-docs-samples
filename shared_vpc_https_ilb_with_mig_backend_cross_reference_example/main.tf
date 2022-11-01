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

# Shared VPC Internal HTTPS load balancer with a managed instance group backend
# Google Cloud Documentation: https://cloud.google.com/load-balancing/docs/l7-internal/l7-internal-shared-vpc
# In this example we use 1 host project & 2 service projects

# Configure the network and subnets in the host project
# https://cloud.google.com/load-balancing/docs/l7-internal/l7-internal-shared-vpc#host-network

# [START cloudloadbalancing_shared_vpc_cross_ref_https_lb_basic]
# [START cloudloadbalancing_shared_vpc_cross_ref_https_lb_network_backend_subnet]
# [START cloudloadbalancing_shared_vpc_cross_ref_https_lb_network]
# Shared VPC network
resource "google_compute_network" "lb_network" {
  name                    = "lb-network"
  provider                = google-beta
  project                 = "my-host-project-id"
  auto_create_subnetworks = false
}
# [END cloudloadbalancing_shared_vpc_cross_ref_https_lb_network]

# [START cloudloadbalancing_shared_vpc_cross_ref_https_lb_backend_sub_network]
# Shared VPC network - backend subnet
resource "google_compute_subnetwork" "lb_frontend_and_backend_subnet" {
  name          = "lb-frontend-and-backend-subnet"
  provider      = google-beta
  project       = "my-host-project-id"
  region        = "us-west1"
  ip_cidr_range = "10.1.2.0/24"
  role          = "ACTIVE"
  network       = google_compute_network.lb_network.id
}
# [END cloudloadbalancing_shared_vpc_cross_ref_https_lb_backend_sub_network]
# [END cloudloadbalancing_shared_vpc_cross_ref_https_lb_network_backend_subnet]

# [START cloudloadbalancing_shared_vpc_cross_ref_https_lb_proxy_sub_network]
# Shared VPC network - proxy-only subnet
resource "google_compute_subnetwork" "proxy_only_subnet" {
  name          = "proxy-only-subnet"
  provider      = google-beta
  project       = "my-host-project-id"
  region        = "us-west1"
  ip_cidr_range = "10.129.0.0/23"
  role          = "ACTIVE"
  purpose       = "REGIONAL_MANAGED_PROXY"
  network       = google_compute_network.lb_network.id
}
# [END cloudloadbalancing_shared_vpc_cross_ref_https_lb_proxy_sub_network]

# [START cloudloadbalancing_shared_vpc_cross_ref_https_lb_firewalls]
# [START cloudloadbalancing_shared_vpc_cross_ref_https_lb_firewalls_ssh]
resource "google_compute_firewall" "fw_allow_ssh" {
  name          = "fw-allow-ssh"
  provider      = google-beta
  project       = "my-host-project-id"
  direction     = "INGRESS"
  network       = google_compute_network.lb_network.id
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["allow-ssh"]
}
# [END cloudloadbalancing_shared_vpc_cross_ref_https_lb_firewalls_ssh]

# [START cloudloadbalancing_shared_vpc_cross_ref_https_lb_firewalls_hc]
resource "google_compute_firewall" "fw_allow_health_check" {
  name          = "fw-allow-health-check"
  provider      = google-beta
  project       = "my-host-project-id"
  direction     = "INGRESS"
  network       = google_compute_network.lb_network.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }
  target_tags = ["load-balanced-backend"]
}
# [END cloudloadbalancing_shared_vpc_cross_ref_https_lb_firewalls_hc]

# [START cloudloadbalancing_shared_vpc_cross_ref_https_lb_firewalls_proxy]
resource "google_compute_firewall" "fw_allow_proxies" {
  name          = "fw-allow-proxies"
  provider      = google-beta
  project       = "my-host-project-id"
  direction     = "INGRESS"
  network       = google_compute_network.lb_network.id
  source_ranges = ["10.129.0.0/23"]
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }
  target_tags = ["load-balanced-backend"]
}
# [END cloudloadbalancing_shared_vpc_cross_ref_https_lb_firewalls_proxy]
# [END cloudloadbalancing_shared_vpc_cross_ref_https_lb_firewalls]

# Config NetworkUser role to use service project
# https://cloud.google.com/load-balancing/docs/l7-internal/l7-internal-shared-vpc#deploy_load_balancer_and_backends
data "google_project" "service_project" {
  project_id = "my-service-project-b-id"
}

resource "google_project_iam_binding" "default" {
  project = "my-host-project-id"
  role    = "roles/compute.networkUser"

  members = [
    "serviceAccount:${data.google_project.service_project.number}@cloudservices.gserviceaccount.com",
  ]
}

# Grant permissions to the Load Balancer Admin to use the backend service
# https://cloud.google.com/load-balancing/docs/l7-internal/l7-internal-shared-vpc#grant-bs-user

resource "google_project_iam_binding" "project_level_iam_lb_access" {
  project = "my-service-project-b-id"
  role    = "roles/compute.loadBalancerServiceUser"

  members = [
    "serviceAccount:${data.google_project.service_project.number}@cloudservices.gserviceaccount.com",
  ]
}

# [START cloudloadbalancing_shared_vpc_cross_ref_https_lb_mig]
# [START cloudloadbalancing_shared_vpc_cross_ref_https_lb_mig_template]
# Instance template
resource "google_compute_instance_template" "default" {
  name     = "l7-ilb-backend-template"
  provider = google-beta
  project  = "my-service-project-b-id"
  region   = "us-west1"
  # For machine type, using small. For more options check https://cloud.google.com/compute/docs/machine-types
  machine_type = "e2-small"
  tags         = ["allow-ssh", "load-balanced-backend"]
  network_interface {
    network    = google_compute_network.lb_network.id
    subnetwork = google_compute_subnetwork.lb_frontend_and_backend_subnet.id
    access_config {
      # add external ip to fetch packages like apache2, ssl
    }
  }
  disk {
    source_image = "debian-cloud/debian-10"
    auto_delete  = true
    boot         = true
  }

  # install apache2 and serve a simple web page
  metadata = {
    startup-script = <<EOF
    #! /bin/bash
    sudo apt-get update
    sudo apt-get install apache2 -y
    sudo a2ensite default-ssl
    sudo a2enmod ssl
    vm_hostname="$(curl -H "Metadata-Flavor:Google" \
    http://metadata.google.internal/computeMetadata/v1/instance/name)"
    sudo echo "Page served from: $vm_hostname" | \
    tee /var/www/html/index.html
    sudo systemctl restart apache2
    EOF
  }
}
# [END cloudloadbalancing_shared_vpc_cross_ref_https_lb_mig_template]

# [START cloudloadbalancing_shared_vpc_cross_ref_https_lb_mig_mgr]
# MIG
resource "google_compute_instance_group_manager" "default" {
  name               = "l7-ilb-backend-example"
  provider           = google-beta
  project            = "my-service-project-b-id"
  zone               = "us-west1-a"
  base_instance_name = "vm"
  target_size        = 2
  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }
  named_port {
    name = "https"
    port = 443
  }
}
# [END cloudloadbalancing_shared_vpc_cross_ref_https_lb_mig_mgr]
# [END cloudloadbalancing_shared_vpc_cross_ref_https_lb_mig]

# [START cloudloadbalancing_shared_vpc_cross_ref_https_lb_config_lb]
# [START cloudloadbalancing_shared_vpc_cross_ref_https_lb_hc]
# health check
resource "google_compute_health_check" "default" {
  name               = "l7-ilb-basic-check"
  provider           = google-beta
  project            = "my-service-project-b-id"
  timeout_sec        = 1
  check_interval_sec = 1
  https_health_check {
    port = "443"
  }
}
# [END cloudloadbalancing_shared_vpc_cross_ref_https_lb_hc]

# [START cloudloadbalancing_shared_vpc_cross_ref_https_lb_backend_service]
# backend service
resource "google_compute_region_backend_service" "default" {
  name                  = "l7-ilb-backend-service"
  provider              = google-beta
  project               = "my-service-project-b-id"
  region                = "us-west1"
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  timeout_sec           = 10
  health_checks         = [google_compute_health_check.default.id]
  backend {
    group           = google_compute_instance_group_manager.default.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}
# [END cloudloadbalancing_shared_vpc_cross_ref_https_lb_backend_service]

# [START cloudloadbalancing_shared_vpc_cross_ref_https_lb_backend_url_map]
# URL map
resource "google_compute_region_url_map" "default" {
  name            = "l7-ilb-map"
  provider        = google-beta
  project         = "my-service-project-a-id"
  region          = "us-west1"
  default_service = google_compute_region_backend_service.default.id
}
# [END cloudloadbalancing_shared_vpc_cross_ref_https_lb_backend_url_map]

# [START cloudloadbalancing_shared_vpc_cross_ref_https_lb_ssl_cert]
# Use self-signed SSL certificate
resource "google_compute_region_ssl_certificate" "default" {
  name        = "l7-ilb-cert"
  provider    = google-beta
  project     = "my-service-project-a-id"
  region      = "us-west1"
  private_key = file("sample-private.key") # path to PEM-formatted file
  certificate = file("sample-server.cert") # path to PEM-formatted file
}
# [END cloudloadbalancing_shared_vpc_cross_ref_https_lb_ssl_cert]

# [START cloudloadbalancing_shared_vpc_cross_ref_https_lb_http_proxy]
# HTTPS target proxy
resource "google_compute_region_target_https_proxy" "default" {
  name             = "l7-ilb-proxy"
  provider         = google-beta
  project          = "my-service-project-a-id"
  region           = "us-west1"
  url_map          = google_compute_region_url_map.default.id
  ssl_certificates = [google_compute_region_ssl_certificate.default.id]
}
# [END cloudloadbalancing_shared_vpc_cross_ref_https_lb_http_proxy]

# [START cloudloadbalancing_shared_vpc_cross_ref_https_lb_fw]
# Forwarding rule
resource "google_compute_forwarding_rule" "default" {
  name                  = "l7-ilb-forwarding-rule"
  provider              = google-beta
  project               = "my-service-project-a-id"
  region                = "us-west1"
  ip_protocol           = "TCP"
  port_range            = "443"
  load_balancing_scheme = "INTERNAL_MANAGED"
  target                = google_compute_region_target_https_proxy.default.id
  network               = google_compute_network.lb_network.id
  subnetwork            = google_compute_subnetwork.lb_frontend_and_backend_subnet.id
  network_tier          = "PREMIUM"
  depends_on            = [google_compute_subnetwork.lb_frontend_and_backend_subnet]
}
# [END cloudloadbalancing_shared_vpc_cross_ref_https_lb_fw]
# [END cloudloadbalancing_shared_vpc_cross_ref_https_lb_config_lb]

# Test instance - To test, use `curl -k -s 'https://LB_IP_ADDRESS:443'`
# [START cloudloadbalancing_shared_vpc_cross_ref_https_lb_test_vm]
resource "google_compute_instance" "vm_test" {
  name         = "client-vm"
  provider     = google-beta
  project      = "my-service-project-a-id"
  zone         = "us-west1-a"
  machine_type = "e2-small"
  tags         = ["allow-ssh"]
  network_interface {
    network    = google_compute_network.lb_network.id
    subnetwork = google_compute_subnetwork.lb_frontend_and_backend_subnet.id
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
}
# [END cloudloadbalancing_shared_vpc_cross_ref_https_lb_test_vm]
# [END cloudloadbalancing_shared_vpc_cross_ref_https_lb_basic]
