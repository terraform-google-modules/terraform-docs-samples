
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

# [START bigquery_create_object_table]
provider "google" {
  project = "bq-huron"
  region  = "us-central1"
}

resource "google_bigquery_connection" "test" {
  connection_id = "my-connection-id"
  location      = "US"
  cloud_resource {}
}

data "google_project" "project" {}

resource "google_project_iam_member" "test" {
  role    = "roles/storage.objectViewer"
  project = data.google_project.project.id
  member  = "serviceAccount:${google_bigquery_connection.test.cloud_resource[0].service_account_id}"
}

resource "google_bigquery_dataset" "test" {
  dataset_id = "my_dataset_id"
}

resource "google_storage_bucket" "test" {
  name                        = "my-bucket-81123"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_bigquery_table" "test" {
  deletion_protection = false
  table_id            = "my-table-id"
  dataset_id          = google_bigquery_dataset.test.dataset_id
  external_data_configuration {
    connection_id = google_bigquery_connection.test.name
    autodetect    = false
    # REQUIRED for object tables.
    object_metadata = "SIMPLE"

    source_uris = [
      "gs://${google_storage_bucket.test.name}/*",
    ]

    # `MANUAL` for manual metadata refresh
    # `AUTOMATIC` for automatic metadata refresh.
    metadata_cache_mode = "MANUAL"
  }

  # `max_staleness` must be specified when `metadata_cache_mode`
  # is `AUTOMATIC`. And omitted when `MANUAL`.
  # encoded as a string encoding of sql IntervalValue type
  # (canonical format).
  # https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types#interval_type
  # max_staleness = "0-0 0 10:0:0"

  # Ensure the connection can access the bucket before table creation.
  # Without this dependency, Terraform may try to create the table when 
  # the connection does not have the correct IAM Role resulting in failures.
  depends_on = [
    google_project_iam_member.test
  ]
}
# [END bigquery_create_object_table]