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


# [START compute_terraform_shutdown_script_file_example]
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
# [END compute_terraform_shutdown_script_file_example]
# [END compute_terraform_shutdown_scriipt_file_example]
