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
* This Terraform code sample creates a BigLake table in
* Google Cloud Storage with an unpartitioned schema.
* For more information, see
* https://cloud.google.com/bigquery/docs/create-cloud-storage-table-biglake
* and
* https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_table
*/

# [START bigquery_create_biglake_unpartitioned_table]
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

# This queries the provider for project information.
data "google_project" "project" {}

# This creates a connection in the US region named "my-connection".
# This connection is used to access the bucket.
resource "google_bigquery_connection" "default" {
  connection_id = "my-connection"
  location      = "US"
  cloud_resource {}
}

# This grants the previous connection IAM role access to the bucket.
resource "google_project_iam_member" "default" {
  role    = "roles/storage.objectViewer"
  project = data.google_project.project.id
  member  = "serviceAccount:${google_bigquery_connection.default.cloud_resource[0].service_account_id}"
}

# This makes the script wait for seven minutes before proceeding.
# This lets IAM permissions propagate.
resource "time_sleep" "wait_7_min" {
  depends_on      = [google_project_iam_member.default]
  create_duration = "7m"
}

# This defines a Google BigQuery dataset with
# default expiration times for partitions and tables, a
# description, a location, and a maximum time travel.
resource "google_bigquery_dataset" "default" {
  dataset_id                      = "my_dataset"
  default_partition_expiration_ms = 2592000000  # 30 days
  default_table_expiration_ms     = 31536000000 # 365 days
  description                     = "My dataset description"
  location                        = "US"
  max_time_travel_hours           = 96 # 4 days

  # This defines a map of labels for the bucket resource,
  # including the labels "billing_group" and "pii".
  labels = {
    billing_group = "accounting",
    pii           = "sensitive"
  }
}


# This creates a BigQuery table named "my_table" in the dataset "default".
# The table has three columns, named "country", "product", and "price", which
# are of types STRING, STRING, and INT64 respectively.
# The table has Automatic Metadata Caching enabled.
# https://cloud.google.com/bigquery/docs/biglake-intro#metadata_caching_for_performance
# `metadata_cache_mode` may be set to `MANUAL` and `max_staleness` ommitted to
# use MANUAL Metadata refresh `metadata_cache_mode` and `max_staleness` may be
# set to omitted to disable the feature.
resource "google_bigquery_table" "default" {
  depends_on = [time_sleep.wait_7_min]
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = "my_table"
  schema = jsonencode([
    { "name" : "country", "type" : "STRING" },
    { "name" : "product", "type" : "STRING" },
    { "name" : "price", "type" : "INT64" }
  ])
  external_data_configuration {
    # This defines an external data configuration for the BigQuery table
    # that reads Parquet data from the publish directory of the default
    # Google Cloud Storage bucket.
    autodetect    = false
    source_format = "PARQUET"
    connection_id = google_bigquery_connection.default.name
    source_uris   = ["gs://${google_storage_bucket.default.name}/data/*"]
    # This enables automatic metadata refresh.
    # `MANUAL` for metadata refresh
    # Omit to disable metadata caching feature.
    metadata_cache_mode = "AUTOMATIC"
  }
  # `max_staleness` must be specified as an interval literal,
  # when `metadata_cache_mode` is `AUTOMATIC`, omitted otherwise.
  # Interval literal: https://cloud.google.com/bigquery/docs/reference/standard-sql/lexical#interval_literals
  # This configures the metadata refresh interval for automatic metadata referesh.
  # Omit if not using automatic metadata refresh
  max_staleness = "0-0 0 10:0:0"

  deletion_protection = false
}
# [END bigquery_create_biglake_unpartitioned_table]