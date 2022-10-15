# [START compute_instance_virtual_display_enabled]

resource "google_compute_instance" "instance_virtual_display" {
  name         = "instance-virtual-display"
  machine_type = "f1-micro"
  zone         = "us-central1-c"

  # Set the below to true to enable virtual display
  enable_display = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
}

# [END compute_instance_virtual_display_enabled]
