/**
* Copyright 2024 Google LLC
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
# [START bigquery_create_spanner_external_dataset]
resource "google_bigquery_dataset" "default" {
  dataset_id    = "my_external_dataset"
  friendly_name = "My external dataset"
  description   = "This is a test description."
  location      = "US"
  external_dataset_reference {
    # The full identifier of your Spanner database.
    external_source = "google-cloudspanner:/projects/my_project/instances/my_instance/databases/my_database"
    # Must be empty for a Spanner external dataset.
    connection = ""
  }
}
# [END bigquery_create_spanner_external_dataset]
