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

# [START cloudrun_service_deploy_tag]
resource "google_cloud_run_v2_service" "default" {
  name     = "cloudrun-srv"
  location = "us-central1"

  template {
    containers {
      # image or tag must be different from previous revision
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
    revision = "cloudrun-srv-blue"
  }

  # Define the traffic split for each revision
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service#traffic
  traffic {
    percent = 100
    # This revision needs to already exist
    revision = "cloudrun-srv-green"
    type     = "TRAFFIC_TARGET_ALLOCATION_TYPE_REVISION"
  }

  traffic {
    # Deploy new revision with 0% traffic
    percent  = 0
    revision = "cloudrun-srv-blue"
    tag      = "tag-name"
    type     = "TRAFFIC_TARGET_ALLOCATION_TYPE_REVISION"
  }
}
# [END cloudrun_service_deploy_tag]
