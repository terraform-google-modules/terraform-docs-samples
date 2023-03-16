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

resource "google_project_service" "notebooks" {
  provider           = google-beta
  service            = "notebooks.googleapis.com"
  disable_on_destroy = false
}

# [START vertex_ai_user_managed_notebooks_instance_basic]
resource "google_notebooks_instance" "basic_instance" {
  name         = "notebooks-instance-basic"
  provider     = google-beta
  location     = "us-central1-a"
  machine_type = "e2-medium"

  vm_image {
    project      = "deeplearning-platform-release"
    image_family = "tf-latest-cpu"
  }

  depends_on = [
    google_project_service.notebooks
  ]
}
# [END vertex_ai_user_managed_notebooks_instance_basic]
