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
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# [START compute_instances_quickstart]

data "google_project" "default" {}

resource "google_compute_network" "default" {
  name                    = "my-custom-network"
  project                 = data.google_project.default.project_id
  auto_create_subnetworks = false # Recommended to have more control
}

resource "google_compute_subnetwork" "default" {
  name          = "my-custom-subnet"
  project       = data.google_project.default.project_id
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1" # Match the region of your VM zone
  network       = google_compute_network.default.id
}

resource "google_compute_instance" "default" {
  name         = "my-vm"
  project      = data.google_project.default.project_id
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11" # Using a common Debian image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.default.id
    # Add an access config to assign an ephemeral public IP
    access_config {}
  }
}
# [END compute_instances_quickstart]
