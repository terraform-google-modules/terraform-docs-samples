# [START functions_v2_basic]
data "google_project" "project" {
  provider = google-beta
}

resource "google_project_service" "cloudfunctions_api" {
  service                    = "cloudfunctions.googleapis.com"
  disable_on_destroy         = false
}

resource "google_project_iam_binding" "project" {
  provider = google-beta
  project = data.google_project.project.id
  role    = "roles/storage.objectViewer"

  members = [
    "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  ]
}

resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "bucket" {
  name     = "${random_id.bucket_prefix.hex}-gcf-source"  # Every bucket name must be globally unique
  location = "US"
  uniform_bucket_level_access = true
}
 
resource "google_storage_bucket_object" "object" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.bucket.name
  source = "function-source.zip"  # Add path to the zipped function source code
}
 
resource "google_cloudfunctions2_function" "function" {
  name = "function-v2"
  location = "us-central1"
  description = "a new function"
 
  build_config {
    runtime = "nodejs16"
    entry_point = "helloHttp"  # Set the entry point 
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.object.name
      }
    }
  }
 
  service_config {
    max_instance_count  = 1
    available_memory    = "256M"
    timeout_seconds     = 60
  }
}

output "function_uri" { 
  value = google_cloudfunctions2_function.function.service_config[0].uri
}
# [END functions_v2_basic]
