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

# [START bigquery_create_iceberg_metadata_table]
# Setup an Example Bucket with this structure.
# Setup Empty Iceberg table in Bucket.
# gs://my-bucket-81123
# ├── data
# └── metadata
#     └── example.metadata.json
resource "google_storage_bucket" "default" {
  name                        = "my-bucket-81123"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
}

# Setup an empty data directory.
resource "google_storage_bucket_object" "empty_data_folder" {
  name    = "data/"
  content = " "
  bucket  = google_storage_bucket.default.name
}

# Upload Metadata File.
resource "google_storage_bucket_object" "metadata" {
  name   = "metadata/example.metadata.json"
  source = "./example.metadata.json"
  bucket = google_storage_bucket.default.name
}

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
  table_id            = "my-iceberg-table"
  dataset_id          = google_bigquery_dataset.default.dataset_id
  external_data_configuration {
    autodetect    = false
    source_format = "ICEBERG"
    # Point to metadata.json.
    source_uris = [
      "gs://${google_storage_bucket.default.name}/metadata/example.metadata.json",
    ]
  }
  # Depends on Iceberg Table Files
  depends_on = [
    google_storage_bucket_object.empty_data_folder,
    google_storage_bucket_object.metadata,
  ]
}
# [START bigquery_create_iceberg_metadata_table]