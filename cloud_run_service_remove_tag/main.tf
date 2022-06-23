# [START cloud_run_service_remove_tag]
resource "google_cloud_run_service" "default" {
  name     = "cloudrun-srv"
  location = "us-central1"

  template {}

  traffic {
    percent       = 100
    # This revision needs to already exist
    revision_name = "cloudrun-srv-green"
  
  }
  traffic {
    # No tags for this revision
    # Keep revision at 0% traffic
    percent       = 0
    # This revision needs to already exist
    revision_name = "cloudrun-srv-blue"
  }
}
# [END cloud_run_service_remove_tag]
