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

# [START eventarc_basic_parent_tag]
# [START eventarc_terraform_enableapis]
# Used to retrieve project_number later
data "google_project" "project" {
  provider = google
}

# Enable Cloud Run API
resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# Enable Eventarc API
resource "google_project_service" "eventarc" {
  service            = "eventarc.googleapis.com"
  disable_on_destroy = false
}

# Enable Pub/Sub API
resource "google_project_service" "pubsub" {
  service            = "pubsub.googleapis.com"
  disable_on_destroy = false
}
# [END eventarc_terraform_enableapis]

# [START storage_terraform_deploy_eventarc]
resource "google_storage_bucket" "default" {
  name          = "${data.google_project.project.name}-bucket"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true
}
# [END storage_terraform_deploy_eventarc]

# [START cloudrun_terraform_deploy_eventarc]
# Deploy Cloud Run service
resource "google_cloud_run_v2_service" "default" {
  name     = "helloworld-events"
  location = "us-east1"

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }

  depends_on = [google_project_service.run]
}

# [END cloudrun_terraform_deploy_eventarc]

# [START eventarc_terraform_pubsub]

# Create a Pub/Sub trigger
resource "google_eventarc_trigger" "trigger_pubsub_tf" {
  name     = "trigger-pubsub-tf"
  location = google_cloud_run_v2_service.default.location

  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }

  destination {
    cloud_run_service {
      service = google_cloud_run_v2_service.default.name
      region  = google_cloud_run_v2_service.default.location
    }
  }

  service_account = "${data.google_project.project.number}-compute@developer.gserviceaccount.com"

  depends_on = [google_project_service.eventarc]
}

# [END eventarc_terraform_pubsub]
# [END eventarc_basic_parent_tag]
