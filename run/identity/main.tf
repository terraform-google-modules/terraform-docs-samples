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

# [START cloudrun_identity_parent_tag]
# [START cloudrun_service_identity_iam]
resource "google_service_account" "cloudrun_service_identity" {
  account_id = "my-service-account"
}
# [END cloudrun_service_identity_iam]

# [START cloudrun_service_identity_run_service]
resource "google_cloud_run_v2_service" "default" {
  name     = "cloud-run-srv"
  location = "us-central1"

  template {
    containers {
      image = "gcr.io/cloudrun/hello"
    }
    service_account = google_service_account.cloudrun_service_identity.email
  }
}
# [END cloudrun_service_identity_run_service]
# [END cloudrun_identity_parent_tag]
