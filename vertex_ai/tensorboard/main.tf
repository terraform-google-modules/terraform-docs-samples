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

# Enable Vertex AI API
resource "google_project_service" "aiplatform" {
  provider           = google
  service            = "aiplatform.googleapis.com"
  disable_on_destroy = false
}

# [START vertex_ai_tensorboard]
resource "google_vertex_ai_tensorboard" "default" {
  display_name = "vertex-ai-tensorboard-sample-name"
  region       = "us-central1"

  depends_on = [
    google_project_service.aiplatform
  ]
}
# [END vertex_ai_tensorboard]
