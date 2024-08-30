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

# [START bigquery_tags_tag_value]
data "google_project" "default" {}

resource "google_tags_tag_key" "env_tag_key" {
  parent     = "projects/${data.google_project.default.project_id}"
  short_name = "env1"
}

resource "google_tags_tag_key" "department_tag_key" {
  parent     = "projects/${data.google_project.default.project_id}"
  short_name = "department1"
}

resource "google_tags_tag_value" "env_tag_value" {
  parent     = "tagKeys/${google_tags_tag_key.env_tag_key.name}"
  short_name = "prod"
}

resource "google_tags_tag_value" "department_tag_value" {
  parent     = "tagKeys/${google_tags_tag_key.department_tag_key.name}"
  short_name = "sales"
}
# [END bigquery_tags_tag_value]
