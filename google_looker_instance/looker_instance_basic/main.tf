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
# [START looker_google_looker_instance_basic]
# Creates a Standard edition Looker (Google Cloud core) instance with basic functionality.
resource "google_looker_instance" "main" {
  name             = "my-instance"
  platform_edition = "LOOKER_CORE_STANDARD"
  region           = "us-central1"
  oauth_config {
    client_id     = "my-client-id"
    client_secret = "my-client-secret"
  }
}
# [END looker_google_looker_instance_basic]
