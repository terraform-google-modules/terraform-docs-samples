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

# [START compute_rmig_min_cpu_platform_and_disk_override_parent_tag]
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google-beta"
      version = ">= 7.14.0"
    }
  }
}

resource "google_compute_instance_template" "default" {
  name         = "example-template"
  machine_type = "n2-standard-2"

  disk {
    auto_delete  = true
    device_name  = "boot"
    boot         = true
    source_image = "projects/debian-cloud/global/images/family/debian-12"
    disk_size_gb = 10
    disk_type    = "pd-balanced"
  }

  network_interface {
    network = "default"
  }
}

# [START compute_rmig_min_cpu_platform_and_disk_override_tag]
resource "google_compute_region_instance_group_manager" "default" {
  provider           = google-beta
  name               = "flex-igm"
  base_instance_name = "flex-igm-instance"
  region             = "us-central1"

  target_size                      = 2
  distribution_policy_target_shape = "ANY"

  version {
    instance_template = google_compute_instance_template.default.id
  }

  instance_flexibility_policy {
    instance_selections {
      name          = "first-preference"
      rank          = 1
      machine_types = ["n4-standard-4"]
      disks {
        auto_delete  = true
        device_name  = "boot"
        boot         = true
        source_image = "projects/debian-cloud/global/images/family/debian-12"
        disk_size_gb = 10
        disk_type    = "hyperdisk-balanced"
      }
    }

    instance_selections {
      name             = "second-preference"
      rank             = 2
      machine_types    = ["n2-standard-4"]
      min_cpu_platform = "Intel Ice Lake"
      disks {
        auto_delete  = true
        device_name  = "boot"
        boot         = true
        source_image = "projects/debian-cloud/global/images/family/debian-12"
        disk_size_gb = 10
        disk_type    = "pd-ssd"
      }
    }
  }

  instance_lifecycle_policy {
    force_update_on_repair = "YES"
  }

  update_policy {
    instance_redistribution_type = "NONE"
    type                         = "OPPORTUNISTIC"
    minimal_action               = "REPLACE"
    max_surge_fixed              = 0
    max_unavailable_fixed        = 6
  }
}
# [END compute_rmig_min_cpu_platform_and_disk_override_tag]
# [END compute_rmig_min_cpu_platform_and_disk_override_parent_tag]
