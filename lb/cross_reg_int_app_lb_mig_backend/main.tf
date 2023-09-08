/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or 
implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# Cross-region internal application load balancer with managed instance 
group backend

# [START cloudloadbalancing_cross_region_int_app_lb_parent_tag]
# VPC
# [START cloudloadbalancing_cross_region_vpc_tag]
resource "google_compute_network" "default" {
  auto_create_subnetworks = false
  name                    = "lb-network-crs-reg"
  provider                = google-beta
}
# [END cloudloadbalancing_cross_region_vpc_tag]

# backend subnet in us-west1
# [START cloudloadbalancing_cross_region_subnet_a_tag]
resource "google_compute_subnetwork" "subnet_a" {
  provider      = google-beta
  ip_cidr_range = "10.1.2.0/24"
  name          = "lbsubnet-uswest1"
  network       = google_compute_network.default.id
  region        = "us-west1"
}
# [END cloudloadbalancing_cross_region_subnet_a_tag]

# backend subnet in us-east1
# [START cloudloadbalancing_cross_region_subnet_b_tag]
resource "google_compute_subnetwork" "subnet_b" {
  provider      = google-beta
  ip_cidr_range = "10.1.3.0/24"
  name          = "lbsubnet-useast1"
  network       = google_compute_network.default.id
  region        = "us-east1"
}
# [END cloudloadbalancing_cross_region_subnet_b_tag]

# proxy-only-subnet in us-east1
# [START cloudloadbalancing_cross_region_proxy_subnet_b_tag]
resource "google_compute_subnetwork" "proxy_subnet_b" {
  provider      = google-beta
  ip_cidr_range = "10.130.0.0/23"
  name          = "proxyonly-subnet2"
  network       = google_compute_network.default.id
  purpose       = "GLOBAL_MANAGED_PROXY"
  region        = "us-east1"
  role          = "ACTIVE"
  lifecycle {
    ignore_changes = [ipv6_access_type]
  }
}
# [END cloudloadbalancing_cross_region_proxy_subnet_b_tag]

# proxy-only-subnet in us-west1
# [START cloudloadbalancing_cross_region_proxy_subnet_a_tag]
resource "google_compute_subnetwork" "proxy_subnet_a" {
  provider      = google-beta
  ip_cidr_range = "10.129.0.0/23"
  name          = "proxyonly-subnet1"
  network       = google_compute_network.default.id
  purpose       = "GLOBAL_MANAGED_PROXY"
  region        = "us-west1"
  role          = "ACTIVE"
  lifecycle {
    ignore_changes = [ipv6_access_type]
  }
}
# [END cloudloadbalancing_cross_region_proxy_subnet_a_tag]

# forwarding-rule in subnet_a
# [START cloudloadbalancing_cross_region_fwd_rule_a_tag]
resource "google_compute_global_forwarding_rule" "fwd_rule_a" {
  provider              = google-beta
  depends_on            = [google_compute_subnetwork.proxy_subnet_a]
  ip_address            = "10.1.2.99"
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  name                  = "gil7forwarding-rule-a"
  network               = google_compute_network.default.id
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  subnetwork            = google_compute_subnetwork.subnet_a.id
}
# [END cloudloadbalancing_cross_region_fwd_rule_a_tag]

# forwarding-rule in subnet_b
# [START cloudloadbalancing_cross_region_fwd_rule_b_tag]
resource "google_compute_global_forwarding_rule" "fwd_rule_b" {
  provider              = google-beta
  depends_on            = [google_compute_subnetwork.proxy_subnet_b]
  ip_address            = "10.1.3.99"
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  name                  = "gil7forwarding-rule-b"
  network               = google_compute_network.default.id
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  subnetwork            = google_compute_subnetwork.subnet_b.id
}
# [END cloudloadbalancing_cross_region_fwd_rule_b_tag]

# Target HTTP proxy
# [START cloudloadbalancing_cross_region_tgt_http_proxy_tag]
resource "google_compute_target_http_proxy" "default" {
  name     = "gil7target-http-proxy"
  provider = google-beta
  url_map  = google_compute_url_map.default.id
}
# [END cloudloadbalancing_cross_region_tgt_http_proxy_tag]

# URL map
# [START cloudloadbalancing_cross_region_url_map_tag]
resource "google_compute_url_map" "default" {
  name            = "gl7-gilb-url-map"
  provider        = google-beta
  default_service = google_compute_backend_service.default.id
}
# [END cloudloadbalancing_cross_region_url_map_tag]

# backend service
# [START cloudloadbalancing_cross_region_bck_service_tag]
resource "google_compute_backend_service" "default" {
  name                  = "gl7-gilb-backend-service"
  provider              = google-beta
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  timeout_sec           = 10
  health_checks         = [google_compute_health_check.default.id]
  backend {
    group           = 
google_compute_region_instance_group_manager.mig_a.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
  backend {
    group           = 
google_compute_region_instance_group_manager.mig_b.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}
# [END cloudloadbalancing_cross_region_bck_service_tag]

# instance template_a
# [START cloudloadbalancing_cross_region_inst_template_a_tag]
resource "google_compute_instance_template" "instance_template_a" {
  name         = "gil7-backendwest1-template"
  provider     = google-beta
  machine_type = "e2-small"
  region       = "us-west1"
  tags         = ["http-server"]

  network_interface {
    network    = google_compute_network.default.id
    subnetwork = google_compute_subnetwork.subnet_a.id
    access_config {
      # add external ip to fetch packages
    }
  }
  disk {
    source_image = "debian-cloud/debian-11"
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

      NAME=$(curl -H "Metadata-Flavor: Google" 
"http://metadata.google.internal/computeMetadata/v1/instance/hostname")
      IP=$(curl -H "Metadata-Flavor: Google" 
"http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
      METADATA=$(curl -f -H "Metadata-Flavor: Google" 
"http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" 
| jq 'del(.["startup-script"])')

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
# [END cloudloadbalancing_cross_region_inst_template_a_tag]

# instance template_b
# [START cloudloadbalancing_cross_region_inst_template_b_tag]
resource "google_compute_instance_template" "instance_template_b" {
  name         = "gil7-backendeast1-template"
  provider     = google-beta
  machine_type = "e2-small"
  region       = "us-east1"
  tags         = ["http-server"]

  network_interface {
    network    = google_compute_network.default.id
    subnetwork = google_compute_subnetwork.subnet_b.id
    access_config {
      # add external ip to fetch packages
    }
  }
  disk {
    source_image = "debian-cloud/debian-11"
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

      NAME=$(curl -H "Metadata-Flavor: Google" 
"http://metadata.google.internal/computeMetadata/v1/instance/hostname")
      IP=$(curl -H "Metadata-Flavor: Google" 
"http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
      METADATA=$(curl -f -H "Metadata-Flavor: Google" 
"http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" 
| jq 'del(.["startup-script"])')

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
# [END cloudloadbalancing_cross_region_inst_template_b_tag]

# health check
# [START cloudloadbalancing_cross_region_health_ckh_tag]
resource "google_compute_health_check" "default" {
  provider = google-beta
  name     = "global-http-health-check"
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}
# [END cloudloadbalancing_cross_region_health_ckh_tag]

# MIG_a
# [START cloudloadbalancing_cross_inst_grp_mgr_a_tag]
resource "google_compute_region_instance_group_manager" "mig_a" {
  name     = "gl7-ilb-miga"
  provider = google-beta
  region   = "us-west1"
  version {
    instance_template = 
google_compute_instance_template.instance_template_a.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 2
}
# [END cloudloadbalancing_cross_inst_grp_mgr_a_tag]

# MIG_b
# [START cloudloadbalancing_cross_inst_grp_mgr_b_tag]
resource "google_compute_region_instance_group_manager" "mig_b" {
  name     = "gl7-ilb-migb"
  provider = google-beta
  region   = "us-east1"
  version {
    instance_template = 
google_compute_instance_template.instance_template_b.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 2
}
# [END cloudloadbalancing_cross_inst_grp_mgr_b_tag]

# allow all access from health check ranges
# [START cloudloadbalancing_cross_firewall_tag]
resource "google_compute_firewall" "fw_healthcheck" {
  name          = "gl7-ilb-fw-allow-hc"
  provider      = google-beta
  direction     = "INGRESS"
  network       = google_compute_network.default.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20"]
  allow {
    protocol = "tcp"
  }
}
# [END cloudloadbalancing_cross_firewall_tag]

# allow http and ssh traffic
# [START cloudloadbalancing_cross_firewall_backend_tag]
resource "google_compute_firewall" "fw_ilb_to_backends" {
  name          = "fw-ilb-to-fw"
  provider      = google-beta
  network       = google_compute_network.default.id
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8080"]
  }
}
# [END cloudloadbalancing_cross_firewall_backend_tag]

# Allow http from proxy subnet to backends
# [START cloudloadbalancing_cross_reg_firewall_proxy_tag]
resource "google_compute_firewall" "fw_backends" {
  name          = "gl7-ilb-fw-allow-ilb-to-backends"
  direction     = "INGRESS"
  network       = google_compute_network.default.id
  source_ranges = ["10.129.0.0/23", "10.130.0.0/23"]
  target_tags   = ["http-server"]
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }
}
# [END cloudloadbalancing_cross_reg_firewall_proxy_tag]

# test instance
# [START cloudloadbalancing_cross_vm_tst_tag]
resource "google_compute_instance" "vm-test" {
  name         = "test-vm"
  provider     = google-beta
  machine_type = "e2-small"
  zone         = "us-west1-a"
  network_interface {
    network    = google_compute_network.default.id
    subnetwork = google_compute_subnetwork.subnet_a.id
    access_config {
      # add external ip
    }
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  # Without this, terraform thinks the image changes each time because
  # bct-staging-images/debian-11 exands to
  # debian-11--basic-gce-staging-bct-20230814-2318. Terraform thinks this 
is a
  # change, causing it to recreate the image.
  lifecycle {
    ignore_changes = [boot_disk]
  }
}
# [END cloudloadbalancing_cross_vm_tst_tag]
# [END cloudloadbalancing_cross_region_int_app_lb_parent_tag]
