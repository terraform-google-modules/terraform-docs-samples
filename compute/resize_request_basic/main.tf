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
 * gcloud compute instance-groups managed resize-requests create igm \
 *    --resize-request=a3-gpu-rr \
 *    --resize-by=3 \
 *    --requested-run-duration=1800 \
 *    --zone=us-central1-a
 */

# [START compute_resize_request_basic_parent_tag]
resource "google_compute_instance_template" "default" {
  description          = "Instance template compatible with Dynamic Workload Scheduler (DWS) resize requests."
  instance_description = "A3 GPU"
  machine_type         = "a3-highgpu-8g"
  region               = "us-central1"

  disk {
    source_image = "cos-cloud/cos-121-lts"
    auto_delete  = true
    boot         = true
    disk_type    = "pd-ssd"
    disk_size_gb = 960
    mode         = "READ_WRITE"
  }

  guest_accelerator {
    type  = "nvidia-h100-80gb"
    count = 8
  }

  scheduling {
    provisioning_model          = "FLEX_START"
    on_host_maintenance         = "TERMINATE"
    instance_termination_action = "DELETE"
    max_run_duration {
      seconds = 3600
      nanos   = 0
    }
  }

  reservation_affinity {
    type = "NO_RESERVATION"
  }

  network_interface {
    network = "default"
  }
}

resource "google_compute_instance_group_manager" "default" {
  name               = "a3-gpu-igm"
  base_instance_name = "a3-gpu-instance"
  zone               = "us-central1-a"

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
  instance_group_manager = google_compute_instance_group_manager.default.name
  zone                   = google_compute_instance_group_manager.default.zone
  name                   = "a3-gpu-rr"
  resize_by              = 3
  requested_run_duration {
    seconds = 1800
  }
}
# [END compute_resize_request_basic_tag]
# [END compute_resize_request_basic_parent_tag]
