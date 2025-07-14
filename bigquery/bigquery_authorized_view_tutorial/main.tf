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


# [START bigquery_authorized_view_tutorial]
/*
Creates an authorized view.
*/


/*
Create a dataset to contain the authorized view.
*/
resource "google_bigquery_dataset" "default" {
  dataset_id  = "authdataset"
  description = "Dataset for authorized view"
  location    = "us-west1"

}

/*
Create the view to authorize.
*/
resource "google_bigquery_table" "default" {
  project             = google_bigquery_dataset.default.project
  dataset_id          = google_bigquery_dataset.default.dataset_id
  table_id            = "authview"
  description         = "View to authorize"
  deletion_protection = false # set to "true" in production

  view {
    query          = "SELECT item_id, avg(rating) FROM `chriscar9.movielens.movielens_1m` GROUP BY item_id ORDER BY item_id;"
    use_legacy_sql = false
  }
  depends_on = [
    google_bigquery_dataset.default
  ]
}

/*
Authorize the view to access the dataset that
the query data originates from.
*/
resource "google_bigquery_dataset_access" "default" {
  project    = "chriscar9"
  dataset_id = "movielens"

  view {
    project_id = google_bigquery_table.default.project
    dataset_id = google_bigquery_table.default.dataset_id
    table_id   = google_bigquery_table.default.table_id
  }
  depends_on = [
    google_bigquery_dataset.default
  ]
}

/*
Set the IAM policy for principals that can access
the authorized view. These users should already have the 
roles/bigqueryUser role at the project level.
*/

data "google_iam_policy" "default" {
  binding {
    role = "roles/bigquery.dataViewer"
    members = [
      "user:nbarn@google.com",
    ]
  }
}

/*
Set the IAM policy on the authorized view.
*/
resource "google_bigquery_table_iam_policy" "default" {
  project     = google_bigquery_table.default.project
  dataset_id  = google_bigquery_dataset.default.dataset_id
  table_id    = "authview"
  policy_data = data.google_iam_policy.default.policy_data
}
# [END bigquery_authorized_view_tutorial]
