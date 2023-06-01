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


# [START aiplatform_create_managed_notebooks_runtime_sample]
resource "google_notebooks_runtime" "basic_runtime" {
  name     = "notebooks-runtime-basic"
  location = "us-central1"

  access_config {
    access_type   = "SINGLE_USER"
    runtime_owner = "admin@hashicorptest.com"
  }

  virtual_machine {
    virtual_machine_config {
      machine_type = "n1-standard-4"
      data_disk {
        initialize_params {
          disk_size_gb = "100"
          disk_type    = "PD_STANDARD"
        }
      }
    }
  }
}
# [END aiplatform_create_managed_notebooks_runtime_sample]

