/**
 * Copyright 2024 Google LLC
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
/*
Create a cron job using Cloud Scheduler
See https://cloud.google.com/scheduler/docs/schedule-run-cron-job-terraform
before running the code snippet.
*/

# [START cloudscheduler_terraform_basic_enableapis]
# Enable Cloud Scheduler API
resource "google_project_service" "scheduler" {
  service            = "cloudscheduler.googleapis.com"
  disable_on_destroy = false
}
# Enable Pub/Sub API
resource "google_project_service" "pubsub" {
  service            = "pubsub.googleapis.com"
  disable_on_destroy = false
}
# [END cloudscheduler_terraform_basic_enableapis]

# [START cloudscheduler_terraform_basic_pubsub_topic]
# Create Pub/Sub topic
resource "google_pubsub_topic" "default" {
  name = "pubsub_topic"
}
# [END cloudscheduler_terraform_basic_pubsub_topic]

# [START cloudscheduler_terraform_basic_pubsub_subscription]
# Create Pub/Sub subscription
resource "google_pubsub_subscription" "default" {
  name  = "pubsub_subscription"
  topic = google_pubsub_topic.default.name
}
# [END cloudscheduler_terraform_basic_pubsub_subscription]

# [START cloudscheduler_terraform_basic_job]
# Create a cron job using Cloud Scheduler
resource "google_cloud_scheduler_job" "default" {
  name        = "test-job"
  description = "test job"
  schedule    = "30 16 * * 7"
  region      = "us-central1"

  pubsub_target {
    topic_name = google_pubsub_topic.default.id
    data       = base64encode("Hello world!")
  }
}
# [END cloudscheduler_terraform_basic_job]
