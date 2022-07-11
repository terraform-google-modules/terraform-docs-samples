# [START cloudrun_service_access_control_run_service]
resource "google_cloud_run_service" "default" {
  name     = "cloud-run-srv"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
# [END cloudrun_service_access_control_run_service]

# [START cloudrun_service_access_control_iam_binding]
resource "google_cloud_run_service_iam_binding" "default" {
  location = google_cloud_run_service.default.location
  service  = google_cloud_run_service.default.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}
# [END cloudrun_service_access_control_iam_binding]
