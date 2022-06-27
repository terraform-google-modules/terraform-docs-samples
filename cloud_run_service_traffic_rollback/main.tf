# [START cloud_run_service_traffic_rollback]
resource "google_cloud_run_service" "default" {
  name     = "cloudrun-srv"
  location = "us-central1"

  template {}

  traffic {
    percent       = 100
    # This revision needs to already exist
    revision_name = "cloudrun-srv-green"
  }
}
# [END cloud_run_service_traffic_rollback]
