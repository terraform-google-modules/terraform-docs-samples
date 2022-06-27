# [START cloud_run_service_traffic_split]
resource "google_cloud_run_service" "default" {
  name     = "cloudrun-srv"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
    metadata {
      name = "cloudrun-srv-green"
    }
  }

  traffic {
    percent       = 25
    revision_name = "cloudrun-srv-green"
  }

  traffic {
    percent       = 75
    # This revision needs to already exist
    revision_name = "cloudrun-srv-blue"
  }
}
# [END cloud_run_service_traffic_split]
