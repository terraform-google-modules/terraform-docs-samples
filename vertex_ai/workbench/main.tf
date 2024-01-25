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


# [START aiplatform_workbench_basic_gpu_instance]
resource "google_workbench_instance" "default" {
  name     = "workbench-instance-example"
  location = "us-central1-a"

  gce_setup {
    machine_type = "n1-standard-1"
    accelerator_configs {
      type       = "NVIDIA_TESLA_T4"
      core_count = 1
    }
    vm_image {
      project = "deeplearning-platform-release"
      family  = "tf-latest-gpu"
    }
  }
}
# [END aiplatform_workbench_basic_gpu_instance]

# [START aiplatform_workbench_basic_metadata]
resource "google_workbench_instance" "default" {
  name     = "workbench-instance-example"
  location = "us-central1-a"

  gce_setup {
    machine_type = "n1-standard-1"
    vm_image {
      project = "deeplearning-platform-release"
      family  = "tf-latest-gpu"
    }
    metadata = {
      key = "value"
    }
  }
}
# [END aiplatform_workbench_basic_metadata]

# [START aiplatform_workbench_updated_metadata]
resource "google_workbench_instance" "default" {
  name     = "workbench-instance-example"
  location = "us-central1-a"

  gce_setup {
    machine_type = "n1-standard-1"
    vm_image {
      project = "deeplearning-platform-release"
      family  = "tf-latest-gpu"
    }
    metadata = {
      key = "updated_value"
    }
  }
}
# [END aiplatform_workbench_updated_metadata]

# [START aiplatform_workbench_removed_metadata]
resource "google_workbench_instance" "default" {
  name     = "workbench-instance-example"
  location = "us-central1-a"

  gce_setup {
    machine_type = "n1-standard-1"
    vm_image {
      project = "deeplearning-platform-release"
      family  = "tf-latest-gpu"
    }
  }
}
# [END aiplatform_workbench_removed_metadata]
