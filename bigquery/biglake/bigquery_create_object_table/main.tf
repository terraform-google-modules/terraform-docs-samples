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
/*
* This sample demonstrates how to create an Object Table in BigQuery.
* For more information please refer to:
* https://cloud.google.com/bigquery/docs/object-table-introduction
* https://cloud.google.com/bigquery/docs/object-tables
*/

# [START bigquery_create_object_table]
# This queries the provider for project information.
data "google_project" "project" {}

# This creates a connection in the US region named "my-connection-id".
# This connection is used to access the bucket.
resource "google_bigquery_connection" "connection" {
  connection_id = "my-connection-id"
  location      = "US"
  cloud_resource {}
}

# This grants the previous connection IAM role access to the bucket.
resource "google_project_iam_member" "iam-permission" {
  role    = "roles/storage.objectViewer"
  project = data.google_project.project.project_id
  member  = "serviceAccount:${google_bigquery_connection.connection.cloud_resource[0].service_account_id}"
}

# This defines a Google BigQuery dataset.
resource "google_bigquery_dataset" "dataset" {
  dataset_id = "my_dataset_id"
}

# This creates a bucket in the US region named "my-bucket" with a pseudorandom suffix.
resource "random_id" "bucket_name_suffix" {
  byte_length = 8
}
resource "google_storage_bucket" "bucket" {
  name                        = "my-bucket-${random_id.bucket_name_suffix.hex}"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
}

# This defines Google BigQuery Object Table with Manual metadata caching, and
# storage defined by `source_uris`.
resource "google_bigquery_table" "table" {
  deletion_protection = false
  table_id            = "my-table-id"
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  external_data_configuration {
    connection_id = google_bigquery_connection.connection.name
    autodetect    = false
    # REQUIRED for object tables.
    object_metadata = "SIMPLE"

    source_uris = [
      "gs://${google_storage_bucket.bucket.name}/*",
    ]

    # `MANUAL` for manual metadata refresh
    # `AUTOMATIC` for automatic metadata refresh.
    metadata_cache_mode = "MANUAL"
  }

  # `max_staleness` must be specified as an interval literal,
  # when `metadata_cache_mode` is `AUTOMATIC`, omitted otherwise.
  # Interval literal: https://cloud.google.com/bigquery/docs/reference/standard-sql/lexical#interval_literals
  # max_staleness = "0-0 0 10:0:0"

  # Ensure the connection can access the bucket before table creation.
  # Without this dependency, Terraform may try to create the table when
  # the connection does not have the correct IAM Role resulting in failures.
  depends_on = [
    google_project_iam_member.iam-permission
  ]
}
# [END bigquery_create_object_table]
