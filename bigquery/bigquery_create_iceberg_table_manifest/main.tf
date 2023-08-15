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

# [START bigquery_create_iceberg_manifest_table]
# Setup an example bucket with `data` and `metadata` directories.
# This will typically be configured by an external source.
# gs://my-bucket-81123
# ├── data
# ├── 00000.parquet
# └── metadata
#     └── table.manifest.json
# A bucket, with an empty 
resource "google_storage_bucket" "default" {
  name                        = "my-bucket-81123"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
}

# Upload a sample parquet file from local file system.
resource "google_storage_bucket_object" "datafile" {
  name   = "data/00000.parquet"
  source = "./00000.parquet"
  bucket = google_storage_bucket.default.name
}

# Upload metadata file
resource "google_storage_bucket_object" "manifest" {
  name    = "metadata/table.manifest.json"
  content = "gs://${google_storage_bucket.default.name}/${google_storage_bucket_object.datafile.name}"
  bucket  = google_storage_bucket.default.name
}


# In this section we create a table pointing to the bucket.
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


resource "google_bigquery_table" "default" {
  deletion_protection = false
  table_id            = "my_file_spec_table"
  dataset_id          = google_bigquery_dataset.default.dataset_id
  external_data_configuration {
    autodetect    = false
    source_format = "PARQUET"
    # Specify URI is a manifest.
    file_set_spec_type = "FILE_SET_SPEC_TYPE_NEW_LINE_DELIMITED_MANIFEST"
    # Point to metadata.json.
    source_uris = [
      "gs://${google_storage_bucket.default.name}/${google_storage_bucket_object.manifest.name}"
    ]
  }
  depends_on = [google_storage_bucket_object.datafile]
}
# [END bigquery_create_iceberg_manifest_table]
