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

# Example of using a public Cloud Run service to call a private one

# [START cloudrun_interservice_parent_tag]
# [START cloudrun_service_interservice_public_service]
resource "google_cloud_run_v2_service" "public" {
  name     = "public-service"
  location = "us-central1"

  deletion_protection = false # set to "true" in production

  template {
    containers {
      # TODO<developer>: replace this with a public service container
      # (This service can be invoked by anyone on the internet)
      image = "us-docker.pkg.dev/cloudrun/container/hello"

      # Include a reference to the private Cloud Run
      # service's URL as an environment variable.
      env {
        name  = "URL"
        value = google_cloud_run_v2_service.private.uri
      }
    }
    # Give the "public" Cloud Run service
    # a service account's identity
    service_account = google_service_account.default.email
  }
}
# [END cloudrun_service_interservice_public_service]

# [START cloudrun_service_interservice_public_policy]
data "google_iam_policy" "public" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "public" {
  location = google_cloud_run_v2_service.public.location
  project  = google_cloud_run_v2_service.public.project
  service  = google_cloud_run_v2_service.public.name

  policy_data = data.google_iam_policy.public.policy_data
}
# [END cloudrun_service_interservice_public_policy]

# [START cloudrun_service_interservice_sa]
resource "google_service_account" "default" {
  account_id   = "cloud-run-interservice-id"
  description  = "Identity used by a public Cloud Run service to call private Cloud Run services."
  display_name = "cloud-run-interservice-id"
}
# [END cloudrun_service_interservice_sa]

# [START cloudrun_service_interservice_private_service]
resource "google_cloud_run_v2_service" "private" {
  name     = "private-service"
  location = "us-central1"

  deletion_protection = false # set to "true" in production

  template {
    containers {
      // TODO<developer>: replace this with a private service container
      // (This service should only be invocable by the public service)
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }
}
# [END cloudrun_service_interservice_private_service]

# [START cloudrun_service_interservice_private_policy]
data "google_iam_policy" "private" {
  binding {
    role = "roles/run.invoker"
    members = [
      "serviceAccount:${google_service_account.default.email}",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "private" {
  location = google_cloud_run_v2_service.private.location
  project  = google_cloud_run_v2_service.private.project
  service  = google_cloud_run_v2_service.private.name

  policy_data = data.google_iam_policy.private.policy_data
}
# [END cloudrun_service_interservice_private_policy]
# [END cloudrun_interservice_parent_tag]
