provider "google-beta" {
  project = "your-project-id"
  region  = "us-central1"
}

data "google_project" "project" {
  project_id = "your-project-id"
}

# Enable Cloud Run API
resource "google_project_service" "cloudrun_api" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# Create Cloud Run Container with gRPC liveness probe
#[START cloud_run_healthchecks_liveness_probe_gRPC]
resource "google_cloud_run_service" "default" {
  provider = google-beta
  name     = "cloudrun-service-healthcheck"
  location = "us-central1"
  metadata {
    annotations = {
      "run.googleapis.com/launch-stage" = "BETA"
    }
  }

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
        liveness_probe {
          failure_threshold = 5
          initial_delay_seconds = 10
          timeout_seconds = 3
          period_seconds = 3
          grpc {
            port = 8080
            service = "grpc.health.v1.Health" # gRPC service should already exist
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
#[END cloud_run_healthchecks_liveness_probe_gRPC]
