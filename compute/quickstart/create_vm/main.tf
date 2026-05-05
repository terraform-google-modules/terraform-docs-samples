/**
 * Copyright 2026 Google LLC
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

# [START compute_instances_quickstart]
# Define a custom VPC network
resource "google_compute_network" "my_network" {
  name                    = "my-custom-network"
  auto_create_subnetworks = false # Recommended to have more control
  project                 = "my-host-project" # Replace with your project
}

# Define a subnetwork within the custom VPC
resource "google_compute_subnetwork" "my_subnet" {
  name          = "my-custom-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1" # Match the region of your VM zone
  network       = google_compute_network.my_network.id
  project       = "my-host-project"
}

resource "google_compute_instance" "default" {
  name         = "my-vm"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"
  project      = "my-host-project"

  boot_disk {
    initialize_params {
      image = "ubuntu-minimal-2210-kinetic-amd64-v20230126"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.my_subnet.id
    access_config {}
  }
}
# [END compute_instances_quickstart]
