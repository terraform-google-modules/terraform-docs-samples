# [START cloud_run_service_deploy_tag]
resource "google_cloud_run_service" "default" {
  name     = "cloudrun-srv"
  location = "us-central1"

  template {
    spec {
      containers {
        # image or tag must be different from previous revision
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
    metadata {
      name = "cloudrun-srv-blue"
    }
  }

  traffic {
    percent       = 100
    # This revision needs to already exist
    revision_name = "cloudrun-srv-green"
  }

  traffic {
    # Deploy new revision with 0% traffic
    percent = 0
    revision_name = "cloudrun-srv-blue"
    tag = "tag-name"
  }
}
# [END cloud_run_service_deploy_tag]
