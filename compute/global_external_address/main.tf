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

# [START compute_global_external_vm_address]
resource "google_compute_address" "default" {
  name   = "my-test-static-ip-address"
  region = "us-central1"
}
# [END compute_global_external_vm_address]

# [START compute_global_external_vm_address_assign]
resource "google_compute_instance" "default" {
  name         = "dns-proxy-nfs"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-1404-trusty-v20160627"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.default.address
    }
  }
}
# [END compute_global_external_vm_address_assign]
