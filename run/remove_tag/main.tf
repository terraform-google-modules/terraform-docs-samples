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

# [START cloudrun_remove_tag_parent_tag]
# [START cloudrun_service_remove_tag]
resource "google_cloud_run_service" "default" {
  name     = "cloudrun-srv"
  location = "us-central1"

  template {}

  traffic {
    percent = 100
    # This revision needs to already exist
    revision_name = "cloudrun-srv-green"

  }
  traffic {
    # No tags for this revision
    # Keep revision at 0% traffic
    percent = 0
    # This revision needs to already exist
    revision_name = "cloudrun-srv-blue"
  }
}
# [END cloudrun_service_remove_tag]
# [END cloudrun_remove_tag_parent_tag]