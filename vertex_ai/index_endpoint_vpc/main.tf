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


# [START aiplatform_create_index_endpoint_vpc_sample]
resource "google_vertex_ai_index_endpoint" "default" {
  display_name = "sample-endpoint"
  description  = "A sample index endpoint within a VPC network"
  region       = "us-central1"
  network      = "projects/${data.google_project.project.number}/global/networks/${google_compute_network.default.name}"
  depends_on = [
    google_service_networking_connection.default
  ]
}

resource "google_service_networking_connection" "default" {
  network                 = google_compute_network.default.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.default.name]
  # Workaround to allow `terraform destroy`, see https://github.com/hashicorp/terraform-provider-google/issues/18729
  deletion_policy = "ABANDON"
}

resource "google_compute_global_address" "default" {
  name          = "sample-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.default.id
}

resource "google_compute_network" "default" {
  name = "sample-network"
}

data "google_project" "project" {}

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
# [END aiplatform_create_index_endpoint_vpc_sample]
