/**
 * Copyright 202 4Google LLC
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
 * gcloud compute instance-groups managed all-instances-config update mig-aic \
 *   --metadata="key1"="value1","key2"="value2" \
 *   --labels="key3"="value3","key4"="value4"
 */

# [START compute_zonal_instance_group_manager_parent_tag]
resource "google_compute_instance_template" "default" {
  name         = "some-instance-template"
  machine_type = "e2-medium"

  disk {
    source_image = "debian-cloud/debian-11"
  }

  network_interface {
    network = "default"
  }
}
# [START compute_zonal_instance_group_manager_simple_tag]
resource "google_compute_instance_group_manager" "default" {

  name               = "mig-aic"
  base_instance_name = "test"
  zone               = "us-central1-f"

  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }

  all_instances_config {
    metadata = {
      key1 = "value1",
      key2 = "value2"
    }
    labels = {
      key3 = "value3",
      key4 = "value4"
    }
  }
}
# [END compute_zonal_instance_group_manager_simple_tag]
# [END compute_zonal_instance_group_manager_parent_tag]
