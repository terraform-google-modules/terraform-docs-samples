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


provider "google" {
  region = "us-central1"
}

# Enable Vertex AI API
resource "google_project_service" "aiplatform" {
  provider           = google
  service            = "aiplatform.googleapis.com"
  disable_on_destroy = false
}

# [START vertex_ai_endpoint]
resource "random_id" "endpoint_id" {
  byte_length = 4
}

resource "google_vertex_ai_endpoint" "default" {
  name         = substr(random_id.endpoint_id.dec, 0, 10)
  display_name = "sample-endpoint"
  description  = "A sample Vertex AI endpoint"
  location     = "us-central1"
  labels = {
    label-one = "value-one"
  }

  depends_on = [
    google_project_service.aiplatform
  ]
}
# [END vertex_ai_endpoint]

