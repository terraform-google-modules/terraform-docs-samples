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

data "google_project" "project" {
}

resource "google_project_service_identity" "gcp_sa_cloud_sql" {
  provider = google-beta
  service  = "sqladmin.googleapis.com"
}

# [START cloud_sql_instance_iam_conditions]
data "google_iam_policy" "sql_iam_policy" {
  binding {
    role = "roles/cloudsql.client"
    members = [
      "serviceAccount:${google_project_service_identity.gcp_sa_cloud_sql.email}",
    ]
    condition {
      expression  = "resource.name == 'projects/${data.google_project.project.project_id}/instances/${google_sql_database_instance.default.name}' && resource.type == 'sqladmin.googleapis.com/Instance'"
      title       = "created"
      description = "Cloud SQL instance creation"
    }
  }
}

resource "google_project_iam_policy" "project" {
  project     = data.google_project.project.project_id
  policy_data = data.google_iam_policy.sql_iam_policy.policy_data
}
# [END cloud_sql_instance_iam_conditions]

resource "google_sql_database_instance" "default" {
  name             = "mysql-instance-iam-condition"
  provider         = google-beta
  region           = "us-central1"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-n1-standard-2"
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
