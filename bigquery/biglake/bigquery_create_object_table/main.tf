/**
* Copyright 2023 Google LLC
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

/**
* This Terraform example creates an object table in BigQuery.
* For more information, see the following links:
* - https://cloud.google.com/bigquery/docs/object-table-introduction
* - https://cloud.google.com/bigquery/docs/object-tables
* - https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_table
*/

# [START bigquery_create_object_table]

# This queries the provider for project information.
data "google_project" "main" {}

# This creates a connection in the US region named "my-connection-id".
# This connection is used to access the bucket.
resource "google_bigquery_connection" "default" {
  connection_id = "my-connection-id"
  location      = "US"
  cloud_resource {}
}

# This grants the previous connection IAM role access to the bucket.
resource "google_project_iam_member" "default" {
  role    = "roles/storage.objectViewer"
  project = data.google_project.main.project_id
  member  = "serviceAccount:${google_bigquery_connection.default.cloud_resource[0].service_account_id}"
}

# This defines a Google BigQuery dataset.
resource "google_bigquery_dataset" "default" {
  dataset_id = "my_dataset_id"
}

# This creates a bucket in the US region named "my-bucket" with a pseudorandom suffix.
resource "random_id" "bucket_name_suffix" {
  byte_length = 8
}
resource "google_storage_bucket" "default" {
  name                        = "my-bucket-${random_id.bucket_name_suffix.hex}"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
}

# This defines a BigQuery object table with manual metadata caching.
resource "google_bigquery_table" "default" {
  deletion_protection = false
  table_id            = "my-table-id"
  dataset_id          = google_bigquery_dataset.default.dataset_id
  external_data_configuration {
    connection_id = google_bigquery_connection.default.name
    autodetect    = false
    # `object_metadata is` required for object tables. For more information, see
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_table#object_metadata
    object_metadata = "SIMPLE"
    # This defines the source for the prior object table.
    source_uris = [
      "gs://${google_storage_bucket.default.name}/*",
    ]

    metadata_cache_mode = "MANUAL"
  }

  # This ensures that the connection can access the bucket
  # before Terraform creates a table.
  depends_on = [
    google_project_iam_member.default
  ]
}
# [END bigquery_create_object_table]
