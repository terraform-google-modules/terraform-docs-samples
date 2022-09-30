# [START cloudrun_service_existing_pubsub]
resource "google_service_account" "sa" {
  account_id   = "cloud-run-pubsub-invoker"
  display_name = "Cloud Run Pub/Sub Invoker"
}

resource "google_cloud_run_service_iam_binding" "binding" {
  location = google_cloud_run_service.default.location
  service  = google_cloud_run_service.default.name
  role     = "roles/run.invoker"
  members  = ["serviceAccount:${google_service_account.sa.email}"]
}

data "google_project" "project" {
}

resource "google_project_service_identity" "pubsub_agent" {
  provider = google-beta
  project  = data.google_project.project.project_id
  service  = "pubsub.googleapis.com"
}

resource "google_project_iam_binding" "project_token_creator" {
  project = data.google_project.project.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  members = ["serviceAccount:${google_project_service_identity.pubsub_agent.email}"]
}

resource "google_pubsub_topic" "default" {
  name = "pubsub_topic"
}

resource "google_pubsub_subscription" "subscription" {
  name  = "pubsub_subscription"
  topic = google_pubsub_topic.default.name
  push_config {
    push_endpoint = google_cloud_run_service.default.status[0].url
    oidc_token {
      service_account_email = google_service_account.sa.email
    }
    attributes = {
      x-goog-version = "v1"
    }
  }
}
# [END cloudrun_service_existing_pubsub]

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
  topic   = google_pubsub_topic.default.name
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}

resource "google_storage_notification" "notification" {
  provider       = google
  bucket         = google_storage_bucket.imageproc_input.name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.default.id
  depends_on     = [google_pubsub_topic_iam_binding.binding]
}
# [END cloudrun_service_image_processing_notifications]