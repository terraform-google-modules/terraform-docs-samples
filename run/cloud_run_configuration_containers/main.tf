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

# Example configuration of a Cloud Run service with command and args

# [START cloudrun_cloud_run_configuration_containers_parent_tag]
# [START cloudrun_service_configuration_containers]
resource "google_cloud_run_service" "default" {
  name     = "cloudrun-service-containers"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"

        # Container "entry-point" command
        # https://cloud.google.com/run/docs/configuring/containers#configure-entrypoint
        command = ["/server"]

        # Container "entry-point" args
        # https://cloud.google.com/run/docs/configuring/containers#configure-entrypoint
        args = []
      }
    }
  }
}
# [END cloudrun_service_configuration_containers]
# [END cloudrun_cloud_run_configuration_containers_parent_tag]