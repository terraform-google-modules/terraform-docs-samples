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

# Example configuration of a Cloud Run service with concurrency set

# [START cloudrun_cloud_run_configuration_concurrency_parent_tag]
# [START cloudrun_service_configuration_concurrency]
resource "google_cloud_run_service" "default" {
  name     = "cloudrun-service-concurrency"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
      # Maximum concurrent requests
      # https://cloud.google.com/run/docs/configuring/concurrency
      container_concurrency = 80
    }
  }
}
# [END cloudrun_service_configuration_concurrency]
# [END cloudrun_cloud_run_configuration_concurrency_parent_tag]