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

# [START bigquery_create_table_attach_tag]

# Create tag keys and values
data "google_project" "default" {}

resource "google_tags_tag_key" "env_tag_key" {
  parent     = "projects/${data.google_project.default.project_id}"
  short_name = "env3"
}

resource "google_tags_tag_key" "department_tag_key" {
  parent     = "projects/${data.google_project.default.project_id}"
  short_name = "department3"
}

resource "google_tags_tag_value" "env_tag_value" {
  parent     = "tagKeys/${google_tags_tag_key.env_tag_key.name}"
  short_name = "prod"
}

resource "google_tags_tag_value" "department_tag_value" {
  parent     = "tagKeys/${google_tags_tag_key.department_tag_key.name}"
  short_name = "sales"
}

# Create a dataset
resource "google_bigquery_dataset" "default" {
  dataset_id                      = "MyDataset"
  default_partition_expiration_ms = 2592000000  # 30 days
  default_table_expiration_ms     = 31536000000 # 365 days
  description                     = "dataset description"
  location                        = "US"
  max_time_travel_hours           = 96 # 4 days
}

# Create a table
resource "google_bigquery_table" "default" {
  dataset_id  = google_bigquery_dataset.default.dataset_id
  table_id    = "mytable"
  description = "table description"

  # Attach tags to the table
  resource_tags = {
    (google_tags_tag_key.env_tag_key.namespaced_name) : google_tags_tag_value.env_tag_value.short_name,
    (google_tags_tag_key.department_tag_key.namespaced_name) : google_tags_tag_value.department_tag_value.short_name
  }
}
# [END bigquery_create_table_attach_tag]
