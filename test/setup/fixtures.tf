/**
 * Copyright 2022 Google LLC
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

# ca pool to use in privateca samples
resource "google_privateca_ca_pool" "default" {
  count = local.num_projects

  project  = local.project_ids[count.index]
  name     = "my-pool"
  location = "us-central1"
  tier     = "ENTERPRISE"
  publishing_options {
    publish_ca_cert = true
    publish_crl     = true
  }
}


# sub ca pool to use in privateca subordinate samples
resource "google_privateca_ca_pool" "subpool" {
  count = local.num_projects

  project  = local.project_ids[count.index]
  name     = "my-sub-pool"
  location = "us-central1"
  tier     = "ENTERPRISE"
  publishing_options {
    publish_ca_cert = true
    publish_crl     = true
  }
}

# enable bigquery reservation fairness
# https://docs.cloud.google.com/bigquery/docs/reservations-tasks#fairness
resource "google_bigquery_job" "query_job" {
  count = local.num_projects

  project = local.project_ids[count.index]

  job_id   = "res_fairness"
  location = "us-central1" # reservations must be made in this region 

  query {
    query          = <<-EOT
      ALTER PROJECT `${local.project_ids[count.index]}`
      SET OPTIONS (
        `region-us-central1.enable_reservation_based_fairness`= true
      );
      EOT
    use_legacy_sql = false
  }
}
