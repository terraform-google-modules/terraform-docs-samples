/**
* Copyright 2026 Google LLC
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

# [START bigtable_create_instance_attach_tag]

data "google_project" "default" {}

resource "google_tags_tag_key" "env_tag_key" {
  parent     = "projects/${data.google_project.default.project_id}"
  short_name = "env"
  deletion_policy = "ABANDON"
}

resource "google_tags_tag_value" "env_tag_value" {
  parent     = "tagKeys/${google_tags_tag_key.env_tag_key.name}"
  short_name = "prod"
  deletion_policy = "ABANDON"
}

resource "google_bigtable_instance" "instance" {
  name                = "my-bigtable-instance"
  deletion_protection = false
  tags = {
    (google_tags_tag_key.env_tag_key.namespaced_name) : google_tags_tag_value.env_tag_value.short_name
  }

  cluster {
    cluster_id   = "my-cluster"
    zone         = "us-central1-a"
    num_nodes    = 1
    storage_type = "SSD"
  }
}

# [END bigtable_create_instance_attach_tag]
