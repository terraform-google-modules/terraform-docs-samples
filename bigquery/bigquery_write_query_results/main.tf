/**
* Copyright 2025 Google LLC
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

# [START bigquery_write_query_results]
# Run a query and write the results to a table.

data "google_project" "default" {
}

# Create a dataset to contain the query results table.
resource "google_bigquery_dataset" "my_dataset" {
  dataset_id  = "my_dataset"
  project     = data.google_project.default.project_id
  description = "Dataset that contains the query results table"
  location    = "US"
}

# Create a table to contain the query results.
resource "google_bigquery_table" "default" {
  table_id            = "results_table"
  description         = "Table that contains the query results"
  dataset_id          = google_bigquery_dataset.my_dataset.dataset_id

  schema = <<EOF
[
  {
    "name": "name",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "total",
    "type": "INTEGER",
    "mode": "NULLABLE"
  }
]
EOF
}

# Generate a unique job ID.
resource "random_string" "job_id" {
  lower   = true
  length  = 16
  special = false

  keepers = {
    uuid = uuid()
  }
}

# Create a query using the generated job ID
# and then write the results to a table.
resource "google_bigquery_job" "my_query_job" {
  job_id = random_string.job_id.id

  query {
    query = "SELECT name, SUM(number) AS total FROM `bigquery-public-data.usa_names.usa_1910_2013` GROUP BY name ORDER BY total DESC LIMIT 100;"

    destination_table {
      project_id = data.google_project.default.project_id
      dataset_id = google_bigquery_dataset.my_dataset.dataset_id
      table_id   = google_bigquery_table.default.table_id
    }
  }
}

# [END bigquery_write_query_results]
