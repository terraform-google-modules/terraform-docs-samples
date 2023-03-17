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

# Featurestore name must be unique for the project
resource "random_id" "featurestore_name_suffix" {
  byte_length = 8
}

# [START vertex_ai_featurestore]
resource "google_vertex_ai_featurestore" "main" {
  name   = "featurestore_${random_id.featurestore_name_suffix.hex}"
  region = "us-central1"
  labels = {
    environment = "testing"
  }

  online_serving_config {
    fixed_node_count = 1
  }

  force_destroy = true
}
# [END vertex_ai_featurestore]
