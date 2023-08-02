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

# [START storage_new_bucket_parent_tag]
# [START storage_create_new_bucket_tf]
# Create new storage bucket in the US multi-region
# with coldline storage
resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "static" {
  name          = "${random_id.bucket_prefix.hex}-new-bucket"
  location      = "US"
  storage_class = "COLDLINE"

  uniform_bucket_level_access = true
}
# [END storage_create_new_bucket_tf]

# [START storage_upload_object_tf]
# Creates a text file based on content_type with content
# in Google Storage Bucket

resource "google_storage_bucket_object" "default" {
  name = "new-object"
  # Uncomment the following to upload an existing object from local file system
  #  source       = "/path/to/an/object"
  content      = "Data as string to be uploaded"
  content_type = "text/plain"
  bucket       = google_storage_bucket.static.id
}
# [END storage_upload_object_tf]

# [START storage_get_object_metadata_tf]
# Get object metadata
data "google_storage_bucket_object" "default" {
  name   = google_storage_bucket_object.default.name
  bucket = google_storage_bucket.static.id
}

output "object_metadata" {
  value = data.google_storage_bucket_object.default
}
# [END storage_get_object_metadata_tf]

# [START storage_get_bucket_metadata_tf]
# Get bucket metadata
data "google_storage_bucket" "default" {
  name = google_storage_bucket.static.id
}

output "bucket_metadata" {
  value = data.google_storage_bucket.default
}
# [END storage_get_bucket_metadata_tf]
# [END storage_new_bucket_parent_tag]
