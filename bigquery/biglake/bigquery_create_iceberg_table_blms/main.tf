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
* This sample creates a BigLake Iceberg Table using a BigLake Metastore URI.
* https://cloud.google.com/bigquery/docs/iceberg-tables#create-using-biglake-metastore
*/

# [START bigquery_create_iceberg_blms]


# This queries the provider for project information.
data "google_project" "project" {}

# Create a Biglake Metastore Catalog named `my_catalog` in the `US`
# A Catalog can contain many Databases.
resource "google_biglake_catalog" "catalog" {
  name     = "my_catalog"
  location = "US"
}

# Create a Cloud Storage Bucket with a unique name in the `US`.
# Generate a random unique suffix.
resource "random_id" "bucket_name_suffix" {
  byte_length = 8
}
resource "google_storage_bucket" "bucket" {
  name                        = "my-bucket-${random_id.bucket_name_suffix.hex}"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
}

# Create a Cloud Storage Directory in `bucket` to store metadata.
resource "google_storage_bucket_object" "metadata_directory" {
  name    = "metadata/"
  content = " "
  bucket  = google_storage_bucket.bucket.name
}

# Create a Cloud Storage Directory in `bucket` to store data.
resource "google_storage_bucket_object" "data_directory" {
  name    = "data/"
  content = " "
  bucket  = google_storage_bucket.bucket.name
}

# Create a Biglake Metastore Database named `my_database` under `catalog` with
# type `HIVE`, and the specified `hive_options`. A Database can contain many
# tables.
resource "google_biglake_database" "database" {
  name    = "my_database"
  catalog = google_biglake_catalog.catalog.id
  type    = "HIVE"
  hive_options {
    location_uri = "gs://${google_storage_bucket.bucket.name}/${google_storage_bucket_object.metadata_directory.name}"
    parameters = {
      "owner" = "Alex"
    }
  }
}

# Create a Biglake Metastore Table name `my-table` under `table` with type
# `HIVE` and the specified `hive_options`.
resource "google_biglake_table" "table" {
  name     = "my-table"
  database = google_biglake_database.database.id
  type     = "HIVE"
  hive_options {
    table_type = "MANAGED_TABLE"
    storage_descriptor {
      location_uri  = "gs://${google_storage_bucket.bucket.name}/${google_storage_bucket_object.data_directory.name}"
      input_format  = "org.apache.hadoop.mapred.SequenceFileInputFormat"
      output_format = "org.apache.hadoop.hive.ql.io.HiveSequenceFileOutputFormat"
    }
    parameters = {
      "spark.sql.create.version"          = "3.1.3"
      "spark.sql.sources.schema.numParts" = "1"
      "transient_lastDdlTime"             = "1680894197"
      "spark.sql.partitionProvider"       = "catalog"
      "owner"                             = "Alex"
      "spark.sql.sources.schema.part.0" = jsonencode({
        "type" : "struct",
        "fields" : [
          { "name" : "id", "type" : "integer",
            "nullable" : true,
            "metadata" : {}
          },
          {
            "name" : "name",
            "type" : "string",
            "nullable" : true,
            "metadata" : {}
          },
          {
            "name" : "age",
            "type" : "integer",
            "nullable" : true,
            "metadata" : {}
          }
        ]
      })
      "spark.sql.sources.provider" = "iceberg"
      "provider"                   = "iceberg"
    }
  }
}

# This defines a Google BigQuery dataset with
# default expiration times for partitions and tables, a
# description, a location, and a maximum time travel.
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

# This defines a Google Bigquery BigLake table referring to the above table.
resource "google_bigquery_table" "default" {
  deletion_protection = false
  table_id            = "my-table-id"
  dataset_id          = google_bigquery_dataset.default.dataset_id
  external_data_configuration {
    autodetect    = false
    source_format = "ICEBERG"
    source_uris = [
      "blms://${google_biglake_table.table.id}"
    ]
  }
}
# [END bigquery_create_iceberg_blms]
