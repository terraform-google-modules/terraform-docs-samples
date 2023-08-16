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

# [START bigquery_create_iceberg_blms]

# ASSUME that there is a valid BLMS URI under:
# blms://projects/myproject/locations/us-central1/catalogs/default/databases/db/tables/tbl

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
  table_id            = "my-table-id"
  dataset_id          = google_bigquery_dataset.default.dataset_id
  external_data_configuration {
    autodetect    = false
    source_format = "ICEBERG"
    # KEY: Point to a BLMS URI.
    source_uris = [
      "blms://projects/myproject/locations/us-central1/catalogs/default/databases/db/tables/tbl",
    ]
  }
}
# [END bigquery_create_iceberg_blms]
