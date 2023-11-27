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
/**
 * Made to resemble:
 * gcloud compute instance-groups managed create igm-stateful-disk-basic \
 *  --template example-tempalte \
 *  --size 1 \
 *  --stateful-disk device-name=bootdisk,auto-delete=NEVER
 */

# [START compute_zonal_mig_stateful_disk_basic_parent_tag]
resource "google_compute_instance_template" "default" {
  name         = "example-template"
  machine_type = "e2-medium"
  disk {
    device_name  = "bootdisk"
    source_image = "debian-cloud/debian-11"
  }
  network_interface {
    network = "default"
  }
}

# [START compute_zonal_mig_stateful_disk_basic]
resource "google_compute_instance_group_manager" "default" {
  name               = "igm-stateful-disk-basic"
  zone               = "us-central1-f"
  base_instance_name = "instance"
  target_size        = 1

  version {
    instance_template = google_compute_instance_template.default.id
  }

  stateful_disk {
    device_name = "bootdisk"
    delete_rule = "NEVER"
  }

}
# [END compute_zonal_mig_stateful_disk_basic]
# [END compute_zonal_mig_stateful_disk_basic_parent_tag]
