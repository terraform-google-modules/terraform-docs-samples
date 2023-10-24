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
* This Terraform code sample creates a BigLake Metastore catalog, database, and
* table. For more information, see
* https://cloud.google.com/bigquery/docs/manage-open-source-metadata and
* https://cloud.google.com/bigquery/docs/reference/biglake/rest
*/

# [START biglake_metastore_create_table]

# This creates a BigLake Metastore in the US region named "my-catalog".
# BigLake Metastore catalogs can contain multiple databases.
resource "google_biglake_catalog" "default" {
  name     = "my_catalog"
  location = "US"
}

# This creates a Cloud Storage Bucket in the `US` with a unique name in the
# `US`.
resource "random_id" "default" {
  byte_length = 8
}
resource "google_storage_bucket" "default" {
  name                        = "my-bucket-${random_id.default.hex}"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
}

# This creates a Google Cloud Storage object to store metadata.
resource "google_storage_bucket_object" "metadata_directory" {
  name    = "metadata/"
  content = " "
  bucket  = google_storage_bucket.default.name
}

# This creates a Google Cloud Storage object to store data.
resource "google_storage_bucket_object" "data_directory" {
  name    = "data/"
  content = " "
  bucket  = google_storage_bucket.default.name
}

# This creates a BigLake Metastore database with the name "my_database" and type
# "HIVE" in the catalog specified by the "google_biglake_catalog.default.id"
# variable.
resource "google_biglake_database" "default" {
  name    = "my_database"
  catalog = google_biglake_catalog.default.id
  type    = "HIVE"
  hive_options {
    location_uri = "gs://${google_storage_bucket.default.name}/${google_storage_bucket_object.metadata_directory.name}"
    parameters = {
      "owner" = "Alex"
    }
  }
}

# This creates a BigLake Metastore table with the name "my_table" and type
# "HIVE" in the database specified by the "google_biglake_database.default.id"
# variable.
resource "google_biglake_table" "default" {
  name     = "my-table"
  database = google_biglake_database.default.id
  type     = "HIVE"
  hive_options {
    table_type = "MANAGED_TABLE"
    storage_descriptor {
      location_uri  = "gs://${google_storage_bucket.default.name}/${google_storage_bucket_object.data_directory.name}"
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
# [END biglake_metastore_create_table]
