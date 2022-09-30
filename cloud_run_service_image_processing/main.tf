# [START cloudrun_service_image_processing_buckets]
resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "google_storage_bucket" "imageproc_input" {
  name     = "input-bucket-${random_id.bucket_suffix.hex}"
  location = "us-central1"
}

resource "google_storage_bucket" "imageproc_output" {
  name     = "output-bucket-${random_id.bucket_suffix.hex}"
  location = "us-central1"
}
# [END cloudrun_service_image_processing_buckets]

# [START cloudrun_service_image_processing_crservice]
resource "google_cloud_run_service" "default" {
  name     = "pubsub-tutorial"
  location = "us-central1"
  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
        env {
          name  = "BLURRED_BUCKET_NAME"
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

# [START cloudrun_service_image_processing_notifications] 
data "google_storage_project_service_account" "gcs_account" {}

resource "google_pubsub_topic_iam_binding" "binding" {
  topic   = google_pubsub_topic.imageproc.name
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}

resource "google_storage_notification" "notification" {
  provider       = google
  bucket         = google_storage_bucket.imageproc_input.name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.imageproc.id
  depends_on     = [google_pubsub_topic_iam_binding.binding]
}
# [END cloudrun_service_image_processing_notifications]