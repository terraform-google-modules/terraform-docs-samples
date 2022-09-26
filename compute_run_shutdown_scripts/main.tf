# [START compute_terraform_shutdown_script_direct_example]
resource "google_compute_instance" "default" {
  name         = "instance-name-shutdown-content-directly"
  machine_type = "f1-micro"
  zone         = "us-central1-c"
  metadata = {
    # Shuts down Apache server
    shutdown-script = "#! /bin/bash /etc/init.d/apache2 stop"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    # A default network is created for all Google Cloud projects
    network = "default"
    access_config {
    }
  }
}
# [END compute_terraform_shutdown_script_direct_example]


# [START compute_terraform_shutdown_scriipt_file_example]
resource "google_compute_instance" "shutdown_content_from_file" {
  name         = "instance-name-shutdown-content-from-file"
  machine_type = "f1-micro"
  zone         = "us-central1-c"
  metadata = {
    # Shuts down Apache server
    shutdown-script = file("${path.module}/shutdown-script.sh")
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    # A default network is created for all Google Cloud projects
    network = "default"
    access_config {
    }
  }
}
# [END compute_terraform_shutdown_scriipt_file_example]
