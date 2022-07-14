# [START cloudrun_service_identity_iam]
resource "google_service_account" "cloudrun_service_identity" {
  account_id   = "my-service-account"
}
# [END cloudrun_service_identity_iam]

# [START cloudrun_service_identity_run_service]
resource "google_cloud_run_service" "default" {
  name     = "cloud-run-srv"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
      }
      service_account_name = google_service_account.cloudrun_service_identity.email  
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
# [END cloudrun_service_identity_run_service]
