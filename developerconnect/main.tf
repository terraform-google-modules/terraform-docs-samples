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

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google-beta"
      version = ">= 6.13.0"
    }
  }
}

# [START developerconnect_create_service_agent_parent_tag]
data "google_project" "default" {
}

# [START developerconnect_service]
resource "google_project_service" "default" {
  service            = "developerconnect.googleapis.com"
  disable_on_destroy = false
}
# [END developerconnect_service]

# [START developerconnect_create_project_level_service_agent]
# Create all project-level developerconnect.googleapis.com service agents
resource "google_project_service_identity" "default" {
  provider = google-beta

  project = data.google_project.default.project_id
  service = "developerconnect.googleapis.com"
}
# [END developerconnect_create_project_level_service_agent]

# [START developerconnect_create_connection]
resource "google_developer_connect_connection" "default" {
  provider      = google-beta
  location      = "us-central1"
  connection_id = "my-connection"

  github_config {
    github_app = "developerconnect"
    # ID of GitHub DeveloperConnect application in the GitHub account/org
    app_installation_id = 123123

    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.default.id
    }
  }
}

resource "google_secret_manager_secret" "default" {
  secret_id = "my-example-secrect"
  replication {
    user_managed {
      replicas {
        location = "us-central1"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "default" {
  secret      = google_secret_manager_secret.default.id
  secret_data = "myuser-github-token"
}

resource "google_secret_manager_secret_iam_member" "default" {
  secret_id  = google_secret_manager_secret.default.id
  role       = "roles/secretmanager.admin"
  member     = "serviceAccount:${google_project_service_identity.default.email}"
  depends_on = [google_secret_manager_secret_version.default]
}
# [END developerconnect_create_connection]

# [START developerconnect_create_git_repository_link]
resource "google_developer_connect_git_repository_link" "default" {
  provider               = google-beta
  location               = "us-central1"
  git_repository_link_id = "my-repo"
  parent_connection      = google_developer_connect_connection.default.connection_id
  clone_uri              = "https://github.com/myuser/myrepo.git"
}
# [END developerconnect_create_git_repository_link]
# [END developerconnect_create_service_agent_parent_tag]