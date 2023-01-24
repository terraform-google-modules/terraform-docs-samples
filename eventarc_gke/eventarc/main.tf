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
# [START terraform_eventarc_gke_initialize]
# Used to retrieve project_number later

data "google_project" "project" {
  provider = google-beta
}

# Enable required services for Eventarc and Eventarc GKE destinations


resource "google_project_service" "eventarc" {
  service            = "eventarc.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudresourcemanager" {
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

# Enable Eventarc to manage GKE clusters
# This is usually done with: gcloud eventarc gke-destinations init
# Eventarc creates a separate Event Forwarder pod for each trigger targeting a# GKE service, and  requires explicit permissions to make changes to the
# cluster. This is done by granting permissions to a special service account
# (the Eventarc P4SA) to manage resources in the cluster. This needs to be done
# once per Google Cloud project.
# Make sure the Eventarc Service Agent is created upfront before
# granting permissions.


resource "google_project_service_identity" "eventarc" {
  provider = google-beta

  service = "eventarc.googleapis.com"
  depends_on = [
    google_project_service.eventarc,
    google_project_service.cloudresourcemanager
  ]
}

resource "google_project_iam_binding" "computeViewer" {
  project = data.google_project.project.id
  role    = "roles/compute.viewer"

  members = ["serviceAccount:service-${data.google_project.project.number}@gcp-sa-eventarc.iam.gserviceaccount.com"]

  depends_on = [google_project_service.eventarc]
}

resource "google_project_iam_binding" "containerDeveloper" {
  project = data.google_project.project.id
  role    = "roles/container.developer"
  members = ["serviceAccount:service-${data.google_project.project.number}@gcp-sa-eventarc.iam.gserviceaccount.com"]

  depends_on = [google_project_service.eventarc]
}

resource "google_project_iam_binding" "serviceAccountAdmin" {
  project = data.google_project.project.id
  role    = "roles/iam.serviceAccountAdmin"

  members = ["serviceAccount:service-${data.google_project.project.number}@gcp-sa-eventarc.iam.gserviceaccount.com"]

  depends_on = [google_project_service.eventarc]
}
# [END terraform_eventarc_gke_initialize]
