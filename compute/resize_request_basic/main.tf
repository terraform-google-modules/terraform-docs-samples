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
 * gcloud compute instance-groups managed resize-requests create igmforrr \
 *    --resize-request=myresizerequest \
 *    --resize-by=3 \
 *    --requested-run-duration=1800 \
 *    --zone=europe-west4-a
 */

# [START compute_resize_request_basic_parent_tag]
resource "google_compute_instance_template" "default" {
  machine_type = "a2-ultragpu-8g"

  disk {
    source_image = "debian-cloud/debian-11"
  }

  network_interface {
    network = "default"
  }
  scheduling {
    on_host_maintenance = "TERMINATE"
  }
  reservation_affinity {
    type = "NO_RESERVATION"
  }
}

resource "google_compute_instance_group_manager" "default" {
  name               = "igmforrr"
  base_instance_name = "test"
  zone               = "europe-west4-a"

  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }
  instance_lifecycle_policy {
    default_action_on_failure = "DO_NOTHING"
  }
}

# [START compute_resize_request_basic_tag]
resource "google_compute_resize_request" "default" {
  provider               = google-beta
  instance_group_manager = google_compute_instance_group_manager.default.name
  zone                   = google_compute_instance_group_manager.default.zone
  name                   = "myresizerequest"
  resize_by              = 3
  requested_run_duration {
    seconds = 1800
  }
}
# [END compute_resize_request_basic_tag]
# [END compute_resize_request_basic_parent_tag]
