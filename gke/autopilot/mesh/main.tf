/**
* Copyright 2025 Google LLC
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

# [START gke_autopilot_mesh]
data "google_project" "default" {}

resource "google_project_service" "default" {
  for_each = toset([
    "meshconfig.googleapis.com"
  ])

  service            = each.value
  disable_on_destroy = false
}

resource "google_container_cluster" "default" {
  name     = "gke-autopilot-mesh"
  location = "us-central1"

  enable_autopilot = true

  fleet {
    project = data.google_project.default.project_id
  }

  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false
}

resource "google_gke_hub_feature" "default" {
  name     = "servicemesh"
  location = "global"

  depends_on = [google_project_service.default]
}


resource "google_gke_hub_feature_membership" "default" {
  location = "global"

  feature             = google_gke_hub_feature.default.name
  membership          = google_container_cluster.default.fleet[0].membership_id
  membership_location = google_container_cluster.default.fleet[0].membership_location

  mesh {
    management = "MANAGEMENT_AUTOMATIC"
  }
}
# [END gke_autopilot_mesh]
