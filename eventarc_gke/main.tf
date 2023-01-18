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

# [START terraform_eventarc_enableapi]
# Used to retrieve project_number later
data "google_project" "project" {
  provider = google-beta
}

# Enable required services for GKE
resource "google_project_service" "container" {
  provider           = google-beta
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

# Create an auto-pilot GKE cluster
resource "google_container_cluster" "gke_cluster" {
  provider = google-beta
  name     = "eventarc-cluster"
  location = "us-central1"

  enable_autopilot = true

  # Needed due to this bug: https://github.com/hashicorp/terraform-provider-google/issues/10782
  ip_allocation_policy {
  }

  depends_on = [google_project_service.container]
}
# [END terraform_eventarc_enableapi]
