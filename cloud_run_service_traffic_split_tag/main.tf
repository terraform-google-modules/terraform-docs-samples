# [START cloud_run_service_traffic_split_tag]
resource "google_cloud_run_service" "default" {
  name     = "cloudrun-srv"
  location = "us-central1"

  template {}

  traffic {
    # Update revision to 50% traffic
    percent       = 50
    # This revision needs to already exist
    revision_name = "cloudrun-srv-green"  
  }

  traffic {
    # Update tag to 50% traffic
    percent = 50
    # This tag needs to already exist
    tag     = "tag-name"  
  }
}
# [END cloud_run_service_traffic_split_tag]
