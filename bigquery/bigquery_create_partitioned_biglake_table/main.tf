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
* This sample creates an Cloud Storage BigLake Table with a partitioning
* scheme.
* https://cloud.google.com/bigquery/docs/create-cloud-storage-table-biglake
*/

# [START bigquery_create_partitioned_biglake_table]
# Create a bucket where the table is stored.
# A pre-existing bucket with files maybe used.

# Cloud Storage bucket name must be unique
resource "random_id" "bucket_name_suffix" {
  byte_length = 8
}
resource "google_storage_bucket" "default" {
  name                        = "my-bucket-${random_id.bucket_name_suffix.hex}"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "default" {
  /*
    The hive partitoned table defined in google_bigquery_table.hive_table
    requires that the partitions locations exist when the table is created, in order to do so
    we have to create this fake message, without it the deployment of the table fails with:

     > Cannot query hive partitioned data for table messages without any associated files

    */
  name    = "publish/dt=2000-01-01/hr=00/min=00/fake_message.json"
  content = "{\"column1\": \"XXX\"}"
  bucket  = google_storage_bucket.default.name
}

# Project information is obtained by provider.
data "google_project" "project" {}

# Create a connection to use to access bucket.
resource "google_bigquery_connection" "default" {
  connection_id = "my-connection"
  location      = "US"
  cloud_resource {}
}

# Grant the Connection access to the bucket.
resource "google_project_iam_member" "default" {
  role    = "roles/storage.objectViewer"
  project = data.google_project.project.id
  member  = "serviceAccount:${google_bigquery_connection.default.cloud_resource[0].service_account_id}"
}

## If you are using schema autodetect, uncomment the following to set up
## a delay to give IAM changes time to propagate.
#resource "time_sleep" "wait_7_min" {
#depends_on = [google_project_iam_member.default]
#create_duration = "7m"
#}

resource "google_bigquery_dataset" "default" {
  dataset_id                      = "mydataset"
  default_partition_expiration_ms = 2592000000  # 30 days
  default_table_expiration_ms     = 31536000000 # 365 days
  description                     = "dataset description"
  location                        = "US"
  max_time_travel_hours           = 96 # 4 days

  labels = {
    billing_group = "accounting",
    pii           = "sensitive"
  }
}


## This creates a table using the connection id.
resource "google_bigquery_table" "default" {
  ## If you are using schema autodetect, uncomment the following to
  ## set up a dependency on the prior delay.
  # depends_on = [time_sleep.wait_7_min]
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = "my_table"
  project    = data.google_project.project.name
  schema     = <<EOF
  [
    {
        "name": "column1",
        "type": "STRING",
        "mode": "NULLABLE"
    }
]
  EOF
  external_data_configuration {
    # Autodetect determines whether schema autodetect is active or inactive.
    autodetect    = false
    source_format = "PARQUET"
    source_uris   = ["gs://${google_storage_bucket.default.name}/publish/*"]
    # [`hive_parititioning_options`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_table.html#hive_partitioning_options) may be specified for partitioned tables.
    hive_partitioning_options {
      mode                     = "CUSTOM"
      source_uri_prefix        = "gs://${google_storage_bucket.default.name}/publish/{dt:STRING}/{hr:STRING}/{min:STRING}"
      require_partition_filter = false
    }

    # Specify either:
    # `MANUAL` for manual metadata refresh
    # `AUTOMATIC` for automatic metadata refresh.
    # metadata_cache_mode = "MANUAL"
  }
  deletion_protection = false

  # `max_staleness` must be specified as an interval literal,
  # when `metadata_cache_mode` is `AUTOMATIC`, omitted otherwise.
  # Interval literal: https://cloud.google.com/bigquery/docs/reference/standard-sql/lexical#interval_literals
  # max_staleness = "0-0 0 10:0:0"
  depends_on = [
    google_storage_bucket_object.default
  ]
}

# [END bigquery_create_partitioned_biglake_table]
