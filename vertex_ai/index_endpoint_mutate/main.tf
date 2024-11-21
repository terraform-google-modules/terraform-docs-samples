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


# [START aiplatform_mutate_index_endpoint_sample]
provider "google" {
  region = "us-central1"
}

resource "google_vertex_ai_index_endpoint_deployed_index" "default" {
  depends_on        = [google_vertex_ai_index_endpoint.default]
  index_endpoint    = google_vertex_ai_index_endpoint.default.id
  index             = google_vertex_ai_index.default.id
  deployed_index_id = "deployed_index_for_mutate"
  # This example assumes the deployed index endpoint's resources configuration
  # differs from the values specified below. Terraform will mutate the deployed
  # index endpoint's resource configuration to match.
  automatic_resources {
    min_replica_count = 3
    max_replica_count = 5
  }
}

resource "google_vertex_ai_index_endpoint" "default" {
  display_name            = "sample-endpoint"
  description             = "A sample index endpoint with a public endpoint"
  region                  = "us-central1"
  public_endpoint_enabled = true
}

# Cloud Storage bucket name must be unique
resource "random_id" "default" {
  byte_length = 8
}

# Create a Cloud Storage bucket
resource "google_storage_bucket" "bucket" {
  name                        = "vertex-ai-index-bucket-${random_id.default.hex}"
  location                    = "us-central1"
  uniform_bucket_level_access = true
}

# Create index content
resource "google_storage_bucket_object" "data" {
  name    = "contents/data.json"
  bucket  = google_storage_bucket.bucket.name
  content = <<EOF
{"id": "42", "embedding": [0.5, 1.0], "restricts": [{"namespace": "class", "allow": ["cat", "pet"]},{"namespace": "category", "allow": ["feline"]}]}
{"id": "43", "embedding": [0.6, 1.0], "restricts": [{"namespace": "class", "allow": ["dog", "pet"]},{"namespace": "category", "allow": ["canine"]}]}
EOF
}

resource "google_vertex_ai_index" "default" {
  region       = "us-central1"
  display_name = "sample-index-batch-update"
  description  = "A sample index for batch update"
  labels = {
    foo = "bar"
  }

  metadata {
    contents_delta_uri = "gs://${google_storage_bucket.bucket.name}/contents"
    config {
      dimensions                  = 2
      approximate_neighbors_count = 150
      distance_measure_type       = "DOT_PRODUCT_DISTANCE"
      algorithm_config {
        tree_ah_config {
          leaf_node_embedding_count    = 500
          leaf_nodes_to_search_percent = 7
        }
      }
    }
  }
  index_update_method = "BATCH_UPDATE"

  timeouts {
    create = "2h"
    update = "1h"
  }
}
# [END aiplatform_mutate_index_endpoint_sample]
