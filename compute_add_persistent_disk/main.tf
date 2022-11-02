resource "google_compute_disk" "default" {
  name = "disk-data"
  type = "pd-standard"
  zone = "us-west1-a"
  size = "5"
}

resource "google_compute_instance" "test_node" {
  name         = "test-node"
  machine_type = "f1-micro"
  zone         = "us-west1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  attached_disk {
    source      = google_compute_disk.default
    device_name = google_compute_disk.default
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }
}
