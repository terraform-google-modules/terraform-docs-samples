resource "google_compute_instance" "mirror" {
  name = "my-instance"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = google_compute_network.default.id
    access_config {
    }
  }
}

resource "google_compute_network" "default" {
  name = "my-network"
}

resource "google_compute_subnetwork" "default" {
  name = "my-subnetwork"
  network       = google_compute_network.default.id
  ip_cidr_range = "10.2.0.0/16"

}

resource "google_compute_region_backend_service" "default" {
  name = "my-service"
  health_checks = [google_compute_health_check.default.id]
}

resource "google_compute_health_check" "default" {
  name = "my-healthcheck"
  check_interval_sec = 1
  timeout_sec        = 1
  tcp_health_check {
    port = "80"
  }
}

resource "google_compute_forwarding_rule" "default" {
  depends_on = [google_compute_subnetwork.default]
  name       = "my-ilb"

  is_mirroring_collector = true
  ip_protocol            = "TCP"
  load_balancing_scheme  = "INTERNAL"
  backend_service        = google_compute_region_backend_service.default.id
  all_ports              = true
  network                = google_compute_network.default.id
  subnetwork             = google_compute_subnetwork.default.id
  network_tier           = "PREMIUM"
}

# [START compute_vm_packet_mirror]
resource "google_compute_packet_mirroring" "foobar" {
  name = "my-mirroring"
  description = "bar"
  network {
    url = google_compute_network.default.id
  }
  collector_ilb {
    url = google_compute_forwarding_rule.default.id
  }
  mirrored_resources {
    tags = ["foo"]
    instances {
      url = google_compute_instance.mirror.id
    }
  }
  filter {
    ip_protocols = ["tcp"]
    cidr_ranges = ["0.0.0.0/0"]
    direction = "BOTH"
  }
}
# [END compute_vm_packet_mirror]
