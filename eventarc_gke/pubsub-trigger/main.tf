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

# [START terraform_eventarc_configure_serviceaccount]
# Used to retrieve project_number later
data "google_project" "project" {
  provider = google-beta
}

# Forwarder to pull events from Pub/Sub

resource "google_service_account" "eventarc_gke_trigger_sa" {
  provider     = google-beta
  account_id   = "eventarc-gke-trigger-sa"
  display_name = "Eventarc GKE Trigger Service Account"
}

# Add right roles to the service account
# The SA must be granted the following roles:
# * roles/pubsub.subscriber
# * roles/monitoring.metricWriter
# * roles/eventarc.eventReceiver (Only for AuditLog triggers. Add it later if needed)


resource "google_project_iam_binding" "project_binding_pubsub_subscriber" {
  provider   = google-beta
  project    = data.google_project.project.id
  role       = "roles/pubsub.subscriber"
  members    = ["serviceAccount:${google_service_account.eventarc_gke_trigger_sa.email}"]
  depends_on = [google_service_account.eventarc_gke_trigger_sa]
}

resource "google_project_iam_binding" "project_binding_monitoring_metricWriter" {
  provider = google-beta
  project  = data.google_project.project.id
  role     = "roles/monitoring.metricWriter"
  members = [
    "serviceAccount:${google_service_account.eventarc_gke_trigger_sa.email}"
  ]
  depends_on = [google_service_account.eventarc_gke_trigger_sa]
}
# [END terraform_eventarc_configure_serviceaccount]

# [START terraform_eventarc_create_pubsub_trigger]
# Create a Pub/Sub trigger
resource "google_eventarc_trigger" "trigger_pubsub_gke" {
  provider = google-beta
  name     = "trigger-pubsub-gke"
  location = "us-central1"
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }


  destination {
    gke {
      cluster   = "eventarc-cluster"
      location  = "us-central1"
      namespace = "default"
      path      = "/"
      service   = "hello-gke"
    }
  }

  service_account = google_service_account.eventarc_gke_trigger_sa.email


  depends_on = [google_service_account.eventarc_gke_trigger_sa, google_project_iam_binding.project_binding_pubsub_subscriber]

}
# [END terraform_eventarc_create_pubsub_trigger]
