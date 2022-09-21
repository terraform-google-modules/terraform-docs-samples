provider "google" {
  project = "muncus-dev2"
}
# [START cloudrun_service_image_processing_datasources]
data "google_project" "project" {}

data "google_storage_project_service_account" "gcs_account" {}
# [END cloudrun_service_image_processing_datasources]

# [START cloudrun_service_image_processing_inputbucket]
# Input Bucket
resource "google_storage_bucket" "imageproc_input" {
 name     = "imageproc-input-bucket"
 location = "us-central1"
}

# IAM: ensure we can read from the input bucket
resource "google_project_iam_member" "input_reader" {
 project = data.google_project.project.project_id
  member = "serviceAccount:${google_cloud_run_service.imageproc.template[0].spec[0].service_account_name}"
  role = "roles/storage.objectViewer"
}
# [END cloudrun_service_image_processing_inputbucket]

# [START cloudrun_service_image_processing_outputbucket]
# Output Bucket
resource "google_storage_bucket" "imageproc_output" {
 name     = "imageproc-output-bucket"
 location = "us-central1"
}

# IAM: Ensure we can write to the output bucket
resource "google_project_iam_member" "output_writer" {
 project = data.google_project.project.project_id
  member = "serviceAccount:${google_cloud_run_service.imageproc.template[0].spec[0].service_account_name}"
  role = "roles/storage.objectCreator"
}
# [END cloudrun_service_image_processing_outputbucket]

# [START cloudrun_service_image_processing_pubsub]
resource "google_pubsub_topic" "imageproc" {
 name = "imageproc-topic"
}

resource "google_pubsub_topic_iam_binding" "binding" {
  topic = google_pubsub_topic.imageproc.name
  role  = "roles/pubsub.publisher"
  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}

# Configure GCS notifications to pubsub
resource "google_storage_notification" "notification" {
  provider       = google
  bucket         = google_storage_bucket.imageproc_input.name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.imageproc.id
  depends_on = [google_pubsub_topic_iam_binding.binding]
}

# Service Account for delivering messages from pubsub to cloud run
resource "google_service_account" "delivery_account" {
  account_id = "imageproc-invoker"
}

# IAM: let this Service Account invoke the Cloud Run service.
resource "google_project_iam_member" "cloud_run_invoker" {
 project = data.google_project.project.project_id
  member = "serviceAccount:${google_service_account.delivery_account.email}"
  role = "roles/run.invoker"
}

# subscription, to deliver pubsub notifications to Cloud Run service.
resource "google_pubsub_subscription" "imageproc_subs" {
  name = "imageproc-cr-sub"
  topic = google_pubsub_topic.imageproc.name
  ack_deadline_seconds = 90
  message_retention_duration = "1200s"
  push_config {
    push_endpoint = google_cloud_run_service.imageproc.status[0].url
    oidc_token {
      service_account_email = google_service_account.delivery_account.email
    }
  }
}
# [END cloudrun_service_image_processing_pubsub]

# [START cloudrun_service_image_processing_crservice]
resource "google_cloud_run_service" "imageproc" {
 name     = "imageproc-tf"
 location = "us-central1"

 template {
   spec {
     containers {
       image = "gcr.io/${data.google_project.project.project_id}/imageproc"
       env {
         name = "BLURRED_BUCKET_NAME"
         value = google_storage_bucket.imageproc_output.name
       }
     }
   }
 }

 traffic {
   percent         = 100
   latest_revision = true
 }
}
# [END cloudrun_service_image_processing_crservice]

