# [START functions_v2_basic]
data "google_project" "project" {
  provider = google-beta
}

resource "google_service_account" "account" {
  account_id = "gcf-sa"
  display_name = "Test Service Account"
}

resource "google_project_iam_member" "bucket" { 
  project = data.google_project.project.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.account.email}"
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
