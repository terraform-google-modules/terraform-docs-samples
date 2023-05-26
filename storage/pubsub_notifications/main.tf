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

# [START storage_pubsub_notifications_parent_tag]
# [START storage_create_pubsub_notifications_tf]
// Create a Pub/Sub notification.
resource "google_storage_notification" "notification" {
  provider       = google-beta
  bucket         = google_storage_bucket.bucket.name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.topic.id
  depends_on     = [google_pubsub_topic_iam_binding.binding]
}

// Enable notifications by giving the correct IAM permission to the unique service account.
data "google_storage_project_service_account" "gcs_account" {
  provider = google-beta
}

// Create a Pub/Sub topic.
resource "google_pubsub_topic_iam_binding" "binding" {
  provider = google-beta
  topic    = google_pubsub_topic.topic.id
  role     = "roles/pubsub.publisher"
  members  = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}

resource "random_id" "bucket_prefix" {
  byte_length = 8
}

// Create a new storage bucket.
resource "google_storage_bucket" "bucket" {
  name                        = "${random_id.bucket_prefix.hex}-example-bucket-name"
  provider                    = google-beta
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_pubsub_topic" "topic" {
  name     = "your_topic_name"
  provider = google-beta
}
# [END storage_create_pubsub_notifications_tf]
# [END storage_pubsub_notifications_parent_tag]