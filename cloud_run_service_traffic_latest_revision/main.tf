# [START cloud_run_service_traffic_latest]
resource "google_cloud_run_service" "default" {
  name     = "cloudrun-srv"
  location = "us-central1"

  template {}

  traffic {
    percent         = 100
    latest_revision = true
  }
}
# [END cloud_run_service_traffic_latest]
