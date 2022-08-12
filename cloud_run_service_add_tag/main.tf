# [START cloudrun_service_add_tag]
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
    # Deploy new revision with 0% traffic
    percent       = 0
    revision_name = "cloudrun-srv-blue"
    tag           = "tag-name"
  }
}
# [END cloudrun_service_add_tag]
