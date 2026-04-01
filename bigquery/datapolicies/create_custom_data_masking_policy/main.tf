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
# [START bigquery_datapolicies_create_custom_masking_policy]
resource "google_bigquery_dataset" "default" {
  dataset_id = "mydataset"
  location   = "US"
}

resource "google_bigquery_routine" "default" {
  dataset_id           = google_bigquery_dataset.default.dataset_id
  routine_id           = "custom_masking_routine"
  routine_type         = "SCALAR_FUNCTION"
  language             = "SQL"
  data_governance_type = "DATA_MASKING"
  definition_body      = "SAFE.REGEXP_REPLACE(ssn, '[0-9]', 'X')"
  return_type          = "{\"typeKind\" :  \"STRING\"}"

  arguments {
    name      = "ssn"
    data_type = "{\"typeKind\" :  \"STRING\"}"
  }
}

resource "google_bigquery_datapolicyv2_data_policy" "default" {
  location         = "US"
  data_policy_id   = "custom_masking_policy"
  data_policy_type = "DATA_MASKING_POLICY"
  data_masking_policy {
    routine = google_bigquery_routine.default.id
  }
}
# [END bigquery_datapolicies_create_custom_masking_policy]

