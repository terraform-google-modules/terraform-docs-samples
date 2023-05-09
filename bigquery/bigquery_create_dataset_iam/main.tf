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

resource "google_project_service" "project" {
  service            = "bigquery.googleapis.com"
  disable_on_destroy = false
}

# [START bigquery_create_dataset_iam]
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

data "google_iam_policy" "auth" {
  binding {
    role = "roles/bigquery.dataOwner"
    members = [
      "user:chriscar@google.com",
    ]
  }
  binding {
    role = "roles/bigquery.admin"
    members = [
      "user:chriscar@google.com",
    ]
  }
  binding {
    role = "roles/bigquery.user"
    members = [
      "group:bigquery-techwriter@google.com",
    ]
  }
  binding {
    role = "roles/bigquery.dataViewer"
    members = [
      "serviceAccount:bqcx-363079734201-pmih@gcp-sa-bigquery-condel.iam.gserviceaccount.com",
    ]
  }
}

resource "google_bigquery_dataset_iam_policy" "dataset_access" {
  dataset_id  = google_bigquery_dataset.default.dataset_id
  policy_data = data.google_iam_policy.auth.policy_data
}
# [END bigquery_create_dataset_iam]
