# [START cloudloadbalancing_rllxlb_example]

# [START cloudloadbalancing_vpc_network_rllxlb_example]
resource "google_compute_network" "default" {
  name                    = "lb-network"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}
# [END cloudloadbalancing_vpc_network_rllxlb_example]

# [START cloudloadbalancing_vpc_subnetwork_rllxlb_example]
resource "google_compute_subnetwork" "default" {
  name                       = "backend-subnet"
  ip_cidr_range              = "10.1.2.0/24"
  network                    = google_compute_network.default.id
  private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"
  purpose                    = "PRIVATE"
  region                     = "us-west1"
  stack_type                 = "IPV4_ONLY"
}
# [END cloudloadbalancing_vpc_subnetwork_rllxlb_example]

# [START cloudloadbalancing_vpc_proxy_subnetwork_rllxlb_example]
resource "google_compute_subnetwork" "proxy_only" {
  name          = "proxy-only-subnet"
  ip_cidr_range = "10.129.0.0/23"
  network       = google_compute_network.default.id
  purpose       = "REGIONAL_MANAGED_PROXY"
  region        = "us-west1"
  role          = "ACTIVE"
}
# [END cloudloadbalancing_vpc_proxy_subnetwork_rllxlb_example]

# [START cloudloadbalancing_health_firewall_rllxlb_example]
resource "google_compute_firewall" "default" {
  name = "fw-allow-health-check"
  allow {
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.default.id
  priority      = 1000
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["load-balanced-backend"]
}
# [END cloudloadbalancing_health_firewall_rllxlb_example]

# [START cloudloadbalancing_proxy_firewall_rllxlb_example]
resource "google_compute_firewall" "allow_proxy" {
  name = "fw-allow-proxies"
  allow {
    ports    = ["443"]
    protocol = "tcp"
  }
  allow {
    ports    = ["80"]
    protocol = "tcp"
  }
  allow {
    ports    = ["8080"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.default.id
  priority      = 1000
  source_ranges = ["10.129.0.0/23"]
  target_tags   = ["load-balanced-backend"]
}
# [END cloudloadbalancing_proxy_firewall_rllxlb_example]

# [START cloudloadbalancing_instance_template_rllxlb_example]
resource "google_compute_instance_template" "default" {
  name = "l7-xlb-backend-template"
  disk {
    auto_delete  = true
    boot         = true
    device_name  = "persistent-disk-0"
    mode         = "READ_WRITE"
    source_image = "projects/debian-cloud/global/images/family/debian-10"
    type         = "PERSISTENT"
  }
  labels = {
    managed-by-cnrm = "true"
  }
  machine_type = "n1-standard-1"
  metadata = {
    startup-script = <<EOF
    #! /bin/bash
    sudo apt-get update
    sudo apt-get install apache2 -y
    sudo a2ensite default-ssl
    sudo a2enmod ssl
    vm_hostname="$(curl -H "Metadata-Flavor:Google" \
    http://169.254.169.254/computeMetadata/v1/instance/name)"
    sudo echo "Page served from: $vm_hostname" | \
    tee /var/www/html/index.html
    sudo systemctl restart apache2
    EOF
  }
  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }
    network    = google_compute_network.default.id
    subnetwork = google_compute_subnetwork.default.id
  }
  region = "us-west1"
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    provisioning_model  = "STANDARD"
  }
  service_account {
    email  = "default"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/pubsub", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }
  tags = ["load-balanced-backend"]
}
# [END cloudloadbalancing_instance_template_rllxlb_example]

# [START cloudloadbalancing_instance_group_rllxlb_example]
resource "google_compute_instance_group_manager" "default" {
  name = "l7-xlb-backend-example"
  zone = "us-west1-a"
  named_port {
    name = "http"
    port = 80
  }
  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 2
}
# [END cloudloadbalancing_instance_group_rllxlb_example]

# [START cloudloadbalancing_ip_address_rllxlb_example]
resource "google_compute_address" "default" {
  name         = "address-name"
  address_type = "EXTERNAL"
  network_tier = "STANDARD"
  region       = "us-west1"
}
# [END cloudloadbalancing_ip_address_rllxlb_example]


# [START cloudloadbalancing_health_check_rllxlb_example]
resource "google_compute_region_health_check" "default" {
  name               = "l7-xlb-basic-check"
  check_interval_sec = 5
  healthy_threshold  = 2
  http_health_check {
    port_specification = "USE_SERVING_PORT"
    proxy_header       = "NONE"
    request_path       = "/"
  }
  region              = "us-west1"
  timeout_sec         = 5
  unhealthy_threshold = 2
}
# [END cloudloadbalancing_health_check_rllxlb_example]

# [START cloudloadbalancing_backend_service_rllxlb_example]
resource "google_compute_region_backend_service" "default" {
  name                  = "l7-xlb-backend-service"
  region                = "us-west1"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_region_health_check.default.id]
  protocol              = "HTTP"
  session_affinity      = "NONE"
  timeout_sec           = 30
  backend {
    group           = google_compute_instance_group_manager.default.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}
# [END cloudloadbalancing_backend_service_rllxlb_example]

# [START cloudloadbalancing_url_map_rllxlb_example]
resource "google_compute_region_url_map" "default" {
  name            = "regional-l7-xlb-map"
  region          = "us-west1"
  default_service = google_compute_region_backend_service.default.id
}
# [END cloudloadbalancing_url_map_rllxlb_example]

# [START cloudloadbalancing_target_http_proxy_rllxlb_example]
resource "google_compute_region_target_http_proxy" "default" {
  name    = "l7-xlb-proxy"
  region  = "us-west1"
  url_map = google_compute_region_url_map.default.id
}
# [END cloudloadbalancing_target_http_proxy_rllxlb_example]

# [START cloudloadbalancing_forwarding_rule_rllxlb_example]
resource "google_compute_forwarding_rule" "default" {
  name       = "l7-xlb-forwarding-rule"
  provider   = google-beta
  depends_on = [google_compute_subnetwork.proxy_only]
  region     = "us-west1"

  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.default.id
  network               = google_compute_network.default.id
  ip_address            = google_compute_address.default.id
  network_tier          = "STANDARD"
}
# [END cloudloadbalancing_forwarding_rule_rllxlb_example]

# [END cloudloadbalancing_rllxlb_example]
