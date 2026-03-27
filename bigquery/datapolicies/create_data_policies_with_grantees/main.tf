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
# [START bigquery_datapolicies_create_raw_data_access_policy]
resource "google_bigquery_datapolicyv2_data_policy" "default" {
  location         = "US"
  data_policy_type = "RAW_DATA_ACCESS_POLICY"
  grantees = [
    "principal://goog/subject/raha@altostrat.com"
  ]
  data_policy_id = "raw_policy"
}
# [END bigquery_datapolicies_create_raw_data_access_policy]

