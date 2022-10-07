# Google Cloud Documentation: https://cloud.google.com/load-balancing/docs/l7-internal/l7-internal-shared-vpc#console
# Shared VPC Internal HTTP load balancer with a managed instance group backend

# https://cloud.devsite.corp.google.com/load-balancing/docs/l7-internal/l7-internal-shared-vpc#host-network

## Configure the subnet for the load balancer's frontend and backends

# Shared VPC network
resource "google_compute_network" "lb_network" {
  name                    = "lb-network"
  provider                = google-beta
  project                 = "my-host-project-357412"
  auto_create_subnetworks = false # custom subnet mode
}

# Shared VPC network - backend subnet
resource "google_compute_subnetwork" "lb_frontend_and_backend_subnet" {
  name          = "lb-frontend-and-backend-subnet"
  provider      = google-beta
  project       = "my-host-project-357412"
  region        = "us-west1"
  ip_cidr_range = "10.1.2.0/24"
  role          = "ACTIVE"
  network       = google_compute_network.lb_network.id
}

# Shared VPC network - proxy-only subnet
resource "google_compute_subnetwork" "proxy_only_subnet" {
  name          = "proxy-only-subnet"
  provider      = google-beta
  project       = "my-host-project-357412"
  region        = "us-west1"
  ip_cidr_range = "10.129.0.0/23"
  role          = "ACTIVE"
  purpose       = "REGIONAL_MANAGED_PROXY"
  network       = google_compute_network.lb_network.id
}

## Configure firewall rules in the host project

resource "google_compute_firewall" "fw_allow_ssh" {
  name          = "fw-allow-ssh"
  provider      = google-beta
  project       = "my-host-project-357412"
  direction     = "INGRESS"
  network       = google_compute_network.lb_network.id
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["allow-ssh"]
}

resource "google_compute_firewall" "fw_allow_health_check" {
  name          = "fw-allow-health-check"
  provider      = google-beta
  project       = "my-host-project-357412"
  direction     = "INGRESS"
  network       = google_compute_network.lb_network.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }
  target_tags = ["load-balanced-backend"]
}

resource "google_compute_firewall" "fw_allow_proxies" {
  name          = "fw-allow-proxies"
  provider      = google-beta
  project       = "my-host-project-357412"
  direction     = "INGRESS"
  network       = google_compute_network.lb_network.id
  source_ranges = ["10.129.0.0/23"]
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }
  target_tags = ["load-balanced-backend"]
}

# https://cloud.google.com/load-balancing/docs/l7-internal/l7-internal-shared-vpc

data "google_project" "service_project02" {
  project_id = "my-service-project-01-358212"
}

# IAM Role
resource "google_project_iam_binding" "default" {
  project = "my-host-project-357412"
  role    = "roles/compute.networkUser"

  members = [
    "serviceAccount:${data.google_project.service_project02.number}@cloudservices.gserviceaccount.com",
  ]
}

## Create the managed instance group backend


# instance template
resource "google_compute_instance_template" "default" {
  name         = "l7-ilb-backend-template"
  provider     = google-beta
  project      = "my-service-project-01-358212"
  region       = "us-west1"
  machine_type = "e2-small" # using small, for more options check https://cloud.google.com/compute/docs/machine-types
  tags         = ["allow-ssh", "load-balanced-backend"]

  network_interface {
    network    = google_compute_network.lb_network.id
    subnetwork = google_compute_subnetwork.lb_frontend_and_backend_subnet.id
    access_config {
      # add external ip to fetch packages
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

# MIG
resource "google_compute_instance_group_manager" "default" {
  name     = "l7-ilb-backend-example"
  provider = google-beta
  project  = "my-service-project-01-358212"
  zone     = "us-west1-a"
  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 2
  named_port {
    name = "http"
    port = 80
  }
}


## Configure the load balance

# health check
resource "google_compute_health_check" "default" {
  name               = "l7-ilb-basic-check"
  provider           = google-beta
  project            = "my-service-project-01-358212"
  timeout_sec        = 1
  check_interval_sec = 1

  http_health_check {
    port = "80"
  }
}

# backend service
resource "google_compute_region_backend_service" "default" {
  name                  = "l7-ilb-backend-service"
  provider              = google-beta
  project               = "my-service-project-01-358212"
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

# URL map
resource "google_compute_region_url_map" "default" {
  name            = "l7-ilb-map"
  provider        = google-beta
  project         = "my-service-project-01-358212"
  region          = "us-west1"
  default_service = google_compute_region_backend_service.default.id
}

# HTTP target proxy
resource "google_compute_region_target_http_proxy" "default" {
  name     = "l7-ilb-proxy"
  provider = google-beta
  project  = "my-service-project-01-358212"
  region   = "us-west1"
  url_map  = google_compute_region_url_map.default.id
}

# Forwarding rule
resource "google_compute_forwarding_rule" "default" {
  name                  = "l7-ilb-forwarding-rule"
  provider              = google-beta
  project               = "my-service-project-01-358212"
  region                = "us-west1"
  ip_protocol           = "TCP"
  port_range            = "80"
  load_balancing_scheme = "INTERNAL_MANAGED"
  target                = google_compute_region_target_http_proxy.default.id
  network               = google_compute_network.lb_network.id
  subnetwork            = google_compute_subnetwork.lb_frontend_and_backend_subnet.id
  network_tier          = "PREMIUM"
  depends_on            = [google_compute_subnetwork.lb_frontend_and_backend_subnet]
}

# Test instance
resource "google_compute_instance" "vm-test" {
  name         = "client-vm"
  provider     = google-beta
  project      = "my-service-project-01-358212"
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



/*
In Client-VM users can use


{
  RESULTS=
  for i in {1..100}
  do
      RESULTS="$RESULTS#$(curl --silent <example_load_balancer_ip_here:80>)"
  done
  echo "***"
  echo "*** Results of load-balancing"
  echo "***"
  echo "$RESULTS" | tr '#' '\n' | grep -Ev "^$" | sort | uniq -c
  echo
}

*/