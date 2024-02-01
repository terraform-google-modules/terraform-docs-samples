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
 * Made to resemble
 * gcloud compute instance-templates create gpu-template \
 * --machine-type n1-standard-2 \
 * --accelerator type=nvidia-tesla-t4,count=1 \
 * --image-family debian-11 \
 * --image-project debian-cloud \
 * --maintenance-policy TERMINATE
*/

# [START compute_template_gpu]
resource "google_compute_instance_template" "default" {
  name         = "gpu-template"
  machine_type = "n1-standard-2"

  disk {
    source_image = "debian-cloud/debian-11"
  }

  network_interface {
    network = "default"
  }

  guest_accelerator {
    type  = "nvidia-tesla-t4"
    count = 1
  }

  scheduling {
    on_host_maintenance = "TERMINATE"
  }
}
# [END compute_template_gpu]
