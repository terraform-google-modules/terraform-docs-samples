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
resource "google_project_service" "cloudrun_api" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# [START cloudrun_service_ingress]
resource "google_cloud_run_v2_service" "default" {
  provider = google-beta
  name     = "ingress-service"
  location = "us-central1"

  # For valid annotation values and descriptions, see
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service#ingress
  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    containers {
      image = "gcr.io/cloudrun/hello" #public image for your service
    }
  }
  # [END cloudrun_service_ingress]
  lifecycle {
    ignore_changes = [
      ingress
    ]
  }
  # [START cloudrun_service_ingress]
}
# [END cloudrun_service_ingress]
