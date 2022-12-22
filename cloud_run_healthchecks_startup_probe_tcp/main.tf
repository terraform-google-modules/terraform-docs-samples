provider "google-beta" {
  project = "tf-cloud-run-healthcheck"
  region  = "us-central1"
}

data "google_project" "project" {
  project_id = "tf-cloud-run-healthcheck"
}

# Enable Cloud Run API
resource "google_project_service" "cloudrun_api" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
  project = "tf-cloud-run-healthcheck"
}

# Create Cloud Run Container with TCP startup probe
#[START cloud_run_healthchecks_startup_probe_tcp]
resource "google_cloud_run_service" "default" {
  provider = google-beta
  name     = "cloudrun-service-healthcheck"
  location = "us-central1"
  project = "tf-cloud-run-healthcheck"

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
        startup_probe {
          failure_threshold = 5
          initial_delay_seconds = 10
          timeout_seconds = 3
          period_seconds = 3
          tcp_socket {
            port = 8080
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
#[END cloud_run_healthchecks_startup_probe_tcp]
