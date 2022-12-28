provider "google-beta" {
  region = "us-central1"
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
          failure_threshold     = 5
          initial_delay_seconds = 10
          timeout_seconds       = 3
          period_seconds        = 3
          http_get {
            path = "/"
            http_headers {
              name  = "Access-Control-Allow-Origin"
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

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
    ]
  }
}
#[END cloud_run_healthchecks_liveness_probe_http]
