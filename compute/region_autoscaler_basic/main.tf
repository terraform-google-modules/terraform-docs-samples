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

# [START compute_region_autoscaler_basic_parent_tag]
resource "google_compute_region_autoscaler" "foobar" {
  name   = "my-region-autoscaler"
  region = "us-central1"
  target = google_compute_region_instance_group_manager.foobar.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}

# [START compute_template_create]
resource "google_compute_instance_template" "foobar" {
  name         = "my-instance-template"
  machine_type = "e2-standard-4"

  disk {
    source_image = "debian-cloud/debian-11"
    disk_size_gb = 250
  }

  network_interface {
    network = "default"

    # default access config, defining external IP configuration
    access_config {
      network_tier = "PREMIUM"
    }
  }

  # To avoid embedding secret keys or user credentials in the instances, Google recommends that you use custom service accounts with the following access scopes.
  service_account {
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
# [END compute_template_create]

resource "google_compute_target_pool" "foobar" {
  name   = "my-target-pool"
  region = "us-central1"
}

resource "google_compute_region_instance_group_manager" "foobar" {
  name   = "my-region-igm"
  region = "us-central1"

  version {
    instance_template = google_compute_instance_template.foobar.id
    name              = "primary"
  }

  target_pools       = [google_compute_target_pool.foobar.id]
  base_instance_name = "foobar"
}
# [END compute_region_autoscaler_basic_parent_tag]
