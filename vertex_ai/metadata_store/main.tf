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


# [START aiplatform_metadata_store_parent_tag]
# [START aiplatform_create_metadata_store_sample]
resource "random_id" "store_prefix" {
  byte_length = 8
}

resource "google_vertex_ai_metadata_store" "main" {
  name        = "${random_id.store_prefix.hex}-test-store"
  description = "Example metadata store"
  provider    = google-beta
  region      = "us-central1"
}
# [END aiplatform_create_metadata_store_sample]
# [END aiplatform_metadata_store_parent_tag]