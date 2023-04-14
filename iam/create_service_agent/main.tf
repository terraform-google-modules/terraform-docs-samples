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

# Google Cloud Documentation: https://cloud.google.com/iam/docs/deny-access#create-deny-policy
# Hashicorp Documentation: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_deny_policy

# [START iam_create_project_level_service_agent]
data "google_project" "default" {
}

# Create all project-level AI Platform service agents
resource "google_project_service_identity" "default" {
    provider = google-beta

    project = data.google_project.default.project_id
    service = "aiplatform.googleapis.com"
}
# [END iam_create_project_level_service_agent]

# [START iam_create_folder_level_service_agent]
data "google_folder" "default" {
}

# Create all folder-level Logging service agents
resource "google_project_service_identity" "folder_level" {
    provider = google-beta

    folder = data.google_folder.default.number
    service = "logging.googleapis.com"
}
# [END iam_create_folder_level_service_agent]

# [START iam_create_folder_level_service_agent]
data "google_organization" "default"{
}

# Create all folder-level Logging service agents
resource "google_project_service_identity" "org_level" {
    provider = google-beta

    folder = data.google_organization.default.number
    service = "logging.googleapis.com"
}
# [END iam_create_folder_level_service_agent]

# [START iam_grant_role_primary_service_agent]
# Grant the primary aiplatform.googleapis.com service agent (AI Platform
# Service Agent) the Vertex AI Service Agent role
# (roles/aiplatform.serviceAgent)
resource "google_project_iam_member" "primary" {
  project = data.google_project.default.project_id
  role    = "roles/aiplatform.serviceAgent"
  member  = "serviceAccount:${google_project_service_identity.default.email}"
}
# [END iam_grant_role_primary_service_agent]

# [START iam_grant_role_non_primary_service_agent]
# Grant the AI Platform Custom Code Service Account the Vertex AI Custom
# Code Service Agent role (roles/aiplatform.customCodeServiceAgent)
resource "google_project_iam_member" "custom_code" {
  project = data.google_project.default.project_id
  role    = "roles/aiplatform.customCodeServiceAgent"
  member  = "serviceAccount:service-${data.google_project.default.number}@gcp-sa-aiplatform-cc.iam.gserviceaccount.com"
}
# [END iam_grant_role_non_primary_service_agent]