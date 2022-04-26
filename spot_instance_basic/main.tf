# [START compute_spot_instace_create]

resource "google_compute_instance" "spot_vm_instance" {
  name         = "spot-instance-name"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  
  scheduling {
      preemptible = true
      automatic_restart = false
      provisioning_model = "SPOT"
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
}

# [END compute_spot_instace_create]
