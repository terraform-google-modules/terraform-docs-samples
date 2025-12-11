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


# [START bigquery_query]
resource "google_bigquery_job" "my_query_job" {
  job_id = "my_query_job"

  query {
    query = "SELECT name, SUM(number) AS total FROM `bigquery-public-data.usa_names.usa_1910_2013` GROUP BY name ORDER BY total DESC LIMIT 10;"
  }
}
# [END bigquery_query]
