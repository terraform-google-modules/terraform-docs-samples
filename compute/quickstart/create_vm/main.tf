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
provider "google" {
  project = "fiery-outpost-445408-c6"
  region  = "asia-southeast3"
  credentials = file("D:\\장진호\\terraform\\gcp-key-json-file\\fiery-outpost-445408-c6-53d7148b215c.json")
}
resource "google_compute_instance" "default" {
  name         = "my-vm"
  machine_type = "n1-standard-1"
  # 나에게 맞는 region을 지정정
  zone         = "asia-southeast3-b"

  boot_disk {
    initialize_params {
      image = "ubuntu-minimal-2210-kinetic-amd64-v20230126"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}
# [END compute_instances_quickstart]
