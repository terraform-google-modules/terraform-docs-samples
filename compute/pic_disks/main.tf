/**
 * Copyright 2024 Google LLC
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
 * gcloud compute instance-groups managed create-instance example-database-mig \
  --instance db-instance \
  --zone us-east1-c \
  --stateful-disk device-name=data-disk,source=projects/example-project/zones/us-east1-c/disks/db-data-disk-1,auto-delete=never
 */

# [START compute_stateful_instance_group_manager_disks_parent_tag]
resource "google_compute_instance_template" "default" {
  machine_type = "e2-medium"
  disk {
    device_name  = "data-disk"
    source_image = "debian-cloud/debian-11"
  }
  network_interface {
    network = "default"
  }
}

resource "google_compute_disk" "default" {
  name = "db-data-disk-1"
  type = "pd-ssd"
  zone = "us-east1-c"
}

resource "google_compute_instance_group_manager" "default" {
  name               = "example-database-mig"
  base_instance_name = "test"
  target_size        = 1
  zone               = google_compute_disk.default.zone
  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }
}

# [START compute_stateful_instance_group_manager_disks_pic]
resource "google_compute_per_instance_config" "default" {
  instance_group_manager = google_compute_instance_group_manager.default.name
  zone                   = google_compute_instance_group_manager.default.zone
  name                   = "db-instance"
  preserved_state {
    disk {
      device_name = "data-disk"
      source      = google_compute_disk.default.id
      delete_rule = "NEVER"
    }
  }
}
# [END compute_stateful_instance_group_manager_disks_pic]
# [END compute_stateful_instance_group_manager_disks_parent_tag]
