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
/** Made to resemble
 * gcloud beta compute instance-groups managed update standby-mig \
 * --standby-policy-mode=scale-out-pool \
 * --standby-policy-initial-delay=50 \
 * --zone=us-central1-f
 */
# [START compute_zonal_instance_group_manager_standby_policy_parent_tag]
resource "google_compute_instance_template" "default" {
  name         = "an-instance-template"
  machine_type = "e2-medium"

  disk {
    source_image = "debian-cloud/debian-11"
  }

  network_interface {
    network = "default"
  }
}

# [START compute_zonal_instance_group_manager_standby_policy_tag]
resource "google_compute_instance_group_manager" "default" {
  provider           = google-beta
  name               = "standby-mig"
  base_instance_name = "test"
  target_size        = 3
  zone               = "us-central1-f"

  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }
  standby_policy {
    initial_delay_sec = 50
    mode              = "SCALE_OUT_POOL"
  }
}
# [END compute_zonal_instance_group_manager_standby_policy_tag]
# [END compute_zonal_instance_group_manager_standby_policy_parent_tag]
