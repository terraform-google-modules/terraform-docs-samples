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

# [START functions_v2_basic_auditlogs]
# This example follows the examples shown in this Google Cloud Community blog post
# https://medium.com/google-cloud/applying-a-path-pattern-when-filtering-in-eventarc-f06b937b4c34
# and the docs https://cloud.google.com/eventarc/docs/path-patterns

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.34.0"
    }
  }
}

resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "source_bucket" {
  name                        = "${random_id.bucket_prefix.hex}-gcf-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "default" {
  type        = "zip"
  output_path = "/tmp/function-source.zip"
  source_dir  = "function-source/"
}

resource "google_storage_bucket_object" "default" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.source_bucket.name
  source = data.archive_file.default.output_path # Path to the zipped function source code
}

resource "google_service_account" "default" {
  account_id   = "test-gcf-sa"
  display_name = "Test Service Account - used for both the cloud function and eventarc trigger in the test"
}

# Note: The right way of listening for Cloud Storage events is to use a Cloud Storage trigger.
# Here we use Audit Logs to monitor the bucket so path patterns can be used in the example of
# google_cloudfunctions2_function below (Audit Log events have path pattern support)
resource "google_storage_bucket" "audit_log_bucket" {
  name                        = "${random_id.bucket_prefix.hex}-gcf-auditlog-bucket"
  location                    = "us-central1" # The trigger must be in the same location as the bucket
  uniform_bucket_level_access = true
}

# Permissions on the service account used by the function and Eventarc trigger
data "google_project" "project" {
}

resource "google_project_iam_member" "invoking" {
  project = data.google_project.project.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_project_iam_member" "event_receiving" {
  project    = data.google_project.project.project_id
  role       = "roles/eventarc.eventReceiver"
  member     = "serviceAccount:${google_service_account.default.email}"
  depends_on = [google_project_iam_member.invoking]
}

resource "google_project_iam_member" "artifactregistry_reader" {
  project    = data.google_project.project.project_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.default.email}"
  depends_on = [google_project_iam_member.event_receiving]
}

resource "google_cloudfunctions2_function" "default" {
  depends_on = [
    google_project_iam_member.event_receiving,
    google_project_iam_member.artifactregistry_reader,
  ]
  name        = "gcf-function"
  location    = "us-central1"
  description = "a new function"

  build_config {
    runtime     = "nodejs22"
    entry_point = "entryPoint" # Set the entry point in the code
    environment_variables = {
      BUILD_CONFIG_TEST = "build_test"
    }
    source {
      storage_source {
        bucket = google_storage_bucket.source_bucket.name
        object = google_storage_bucket_object.default.name
      }
    }
  }

  service_config {
    max_instance_count = 3
    min_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
    environment_variables = {
      SERVICE_CONFIG_TEST = "config_test"
    }
    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.default.email
  }

  event_trigger {
    trigger_region        = "us-central1" # The trigger must be in the same location as the bucket
    event_type            = "google.cloud.audit.log.v1.written"
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = google_service_account.default.email
    event_filters {
      attribute = "serviceName"
      value     = "storage.googleapis.com"
    }
    event_filters {
      attribute = "methodName"
      value     = "storage.objects.create"
    }
    event_filters {
      attribute = "resourceName"
      # Selects all .txt files in the bucket
      value = "/projects/_/buckets/${google_storage_bucket.audit_log_bucket.name}/objects/*.txt"
      # Allows path patterns to be used in the value field
      operator = "match-path-pattern"
    }
  }
}
# [END functions_v2_basic_auditlogs]
