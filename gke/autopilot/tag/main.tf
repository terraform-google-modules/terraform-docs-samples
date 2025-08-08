/**
* Copyright 2024 Google LLC
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

# [START gke_autopilot_tag]
resource "google_container_cluster" "default" {
  name     = "gke-autopilot-tag"
  location = "us-central1"

  enable_autopilot = true
}

data "google_project" "default" {}

resource "google_tags_tag_key" "default" {
  parent      = "projects/${data.google_project.default.project_id}"
  short_name  = "env"
  description = "Environment tag key"
}

resource "google_tags_tag_value" "default" {
  parent      = "tagKeys/${google_tags_tag_key.default.name}"
  short_name  = "dev"
  description = "Development environment tag value."
}

resource "google_tags_location_tag_binding" "default" {
  parent    = "//container.googleapis.com/${google_container_cluster.default.id}"
  location  = google_container_cluster.default.location
  tag_value = "tagValues/${google_tags_tag_value.default.name}"
}
# [END gke_autopilot_tag]
