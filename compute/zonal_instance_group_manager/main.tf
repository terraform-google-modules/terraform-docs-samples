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

# [START compute_zonal_instance_group_manager_parent_tag]
data "google_compute_image" "debian_11" {

  family  = "debian-11"
  project = "debian-cloud"
}

resource "google_compute_instance_template" "default" {
  name           = "my-instance-template"
  machine_type   = "e2-medium"
  can_ip_forward = false

  tags = ["tag1", "tag2"]

  disk {
    source_image = data.google_compute_image.debian_11.id
  }

  network_interface {
    network = "default"
  }

  metadata = {
    name = "value"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

# [START compute_zonal_instance_group_manager_simple_tag]
resource "google_compute_instance_group_manager" "default" {

  name = "my-igm"
  zone = "us-central1-f"

  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }

  base_instance_name = "my-igms-instance"
}

# [END compute_zonal_instance_group_manager_simple_tag]
# [END compute_zonal_instance_group_manager_parent_tag]
