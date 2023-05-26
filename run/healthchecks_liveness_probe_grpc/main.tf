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

provider "google-beta" {
  region = "us-central1"
}

# Enable Cloud Run API
# [START cloudrun_healthchecks_liveness_probe_grpc_parent_tag]
resource "google_project_service" "cloudrun_api" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# Create Cloud Run Container with gRPC liveness probe
#[START cloud_run_healthchecks_liveness_probe_gRPC]
resource "google_cloud_run_service" "default" {
  provider = google-beta
  name     = "cloudrun-service-healthcheck"
  location = "us-central1"

  template {
    spec {
      containers {
        # Note: Change to the name of your image
        image = "us-docker.pkg.dev/cloudrun/container/hello"

        liveness_probe {
          failure_threshold     = 5
          initial_delay_seconds = 10
          timeout_seconds       = 3
          period_seconds        = 3

          # Note: Change to the name of your pre-existing grpc health status service
          grpc {
            service = "grpc.health.v1.Health"
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
#[END cloud_run_healthchecks_liveness_probe_gRPC]
# [END cloudrun_healthchecks_liveness_probe_grpc_parent_tag]