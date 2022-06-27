# [START cloud_run_service_traffic_gradual_rollout]
resource "google_cloud_run_service" "default" {
  name     = "cloudrun-srv"
  location = "us-central1"

  template {
    spec {
      containers {
        # Image or image tag must be different from previous revision
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }
  autogenerate_revision_name = true

  traffic {
    percent       = 100
    # This revision needs to already exist
    revision_name = "cloudrun-srv-green"
  
  }

  traffic {
    # Deploy new revision with 0% traffic
    percent         = 0
    latest_revision = true
  }
}
# [END cloud_run_service_traffic_gradual_rollout]
