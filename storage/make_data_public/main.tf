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

# [START storage_make_data_public_parent_tag]
resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "default" {
  provider                    = google
  name                        = "${random_id.bucket_prefix.hex}-example-bucket-name"
  location                    = "US"
  uniform_bucket_level_access = true
}

# [START storage_make_data_public]
# Make bucket public
resource "google_storage_bucket_iam_member" "member" {
  provider = google
  bucket   = google_storage_bucket.default.name
  role     = "roles/storage.objectViewer"
  member   = "allUsers"
}
# [END storage_make_data_public]
# [END storage_make_data_public_parent_tag]
