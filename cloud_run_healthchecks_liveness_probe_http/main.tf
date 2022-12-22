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

# Create Cloud Run Container with HTTP liveness probe
#[START cloud_run_healthchecks_liveness_probe_http]
resource "google_cloud_run_service" "default" {
  provider = google-beta
  name     = "cloudrun-service-healthcheck"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
        liveness_probe {
          failure_threshold = 5
          initial_delay_seconds = 10
          timeout_seconds = 3
          period_seconds = 3
          http_get {
            path = "/"
            http_headers {
              name = "Access-Control-Allow-Origin"
              value = "*"
            }
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
#[END cloud_run_healthchecks_liveness_probe_http]
