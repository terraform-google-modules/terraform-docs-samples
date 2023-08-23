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

# Example configuration of a Cloud Run service with CPU limit

# [START cloudrun_service_configuration_cpu_allocation]
resource "google_cloud_run_v2_service" "default" {
  name     = "cloudrun-service-cpu-allocation"
  location = "us-central1"

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      resources {
        # If true, garbage-collect CPU when once a request finishes
        cpu_idle = false
      }
    }
  }
}
# [END cloudrun_service_configuration_cpu_allocation]
