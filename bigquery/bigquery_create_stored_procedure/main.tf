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


# [START bigquery_create_stored_procedure]
# Creates a SQL stored procedure.

# Create a dataset to contain the stored procedure.
resource "google_bigquery_dataset" "my_dataset" {
  dataset_id = "my_dataset"
}

# Create a stored procedure.
resource "google_bigquery_routine" "my_stored_procedure" {
  dataset_id      = google_bigquery_dataset.my_dataset.dataset_id
  routine_id      = "my_stored_procedure"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = "SELECT * FROM `bigquery-public-data.ml_datasets.penguins`;"
}
# [END bigquery_create_stored_procedure]
