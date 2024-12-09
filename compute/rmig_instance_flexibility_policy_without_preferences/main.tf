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
* gcloud compute instance-groups managed create flex-igm \
* --region us-central1 \
* --size 3 \
* --template example-template \
* --target-distribution-shape=any-single-zone \
* --instance-redistribution-type none \
* --instance-selection-machine-types "machine-type=n1-standard-16,n2-standard-16,e2-standard-16"
*/

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.13.0"
    }
  }
}

# [START compute_region_igm_instance_flexibility_policy_parent_tag]
resource "google_compute_instance_template" "default" {
  name         = "example-template"
  machine_type = "e2-medium"
  disk {
    source_image = "debian-cloud/debian-11"
  }
  network_interface {
    network = "default"
  }
}

# [START compute_region_igm_instance_flexibility_policy]
resource "google_compute_region_instance_group_manager" "default" {
  name               = "flex-igm"
  base_instance_name = "tf-test-flex-igm"
  region             = "us-central1"

  target_size                      = 3
  distribution_policy_target_shape = "ANY_SINGLE_ZONE"

  version {
    instance_template = google_compute_instance_template.default.id
  }

  instance_flexibility_policy {
    instance_selections {
      name          = "default-instance-selection"
      machine_types = ["n1-standard-16", "n2-standard-16", "e2-standard-16"]
    }
  }

  update_policy {
    instance_redistribution_type = "NONE"
    type                         = "OPPORTUNISTIC"
    minimal_action               = "REPLACE"
    max_surge_fixed              = 0
    max_unavailable_fixed        = 6
  }
}
# [END compute_region_igm_instance_flexibility_policy]
# [END compute_region_igm_instance_flexibility_policy_parent_tag]
