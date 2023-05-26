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

# [START compute_instance_virtual_display_enabled_parent_tag]
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
# [END compute_instance_virtual_display_enabled_parent_tag]