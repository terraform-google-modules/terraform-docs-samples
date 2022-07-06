resource "google_project_service" "run_api" {
  project                    = "my-project-name"
  service                    = "run.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "iam_api" {
  project                    = "my-project-name"
  service                    = "iam.googleapis.com"
  disable_on_destroy         = false
}

resource "google_project_service" "resource_manager_api" {
  project                    = "my-project-name"
  service                    = "cloudresourcemanager.googleapis.com"
  disable_on_destroy         = false
}

resource "google_project_service" "scheduler_api" {
  project                    = "my-project-name"
  service                    = "cloudscheduler.googleapis.com"
  disable_on_destroy         = false
}

# [START cloudrun_service_scheduled]
resource "google_cloud_run_service" "default" {
  project  = "my-project-name"
  name     = "my-scheduled-service"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  # Use an explicit depends_on clause to wait until API is enabled
  depends_on = [
    google_project_service.run_api
  ]
}

resource "google_service_account" "default" {
  project      = "my-project-name"
  account_id   = "scheduler-sa"
  description  = "Cloud Scheduler service account; used to trigger scheduled Cloud Run jobs."
  display_name = "scheduler-sa"

  # Use an explicit depends_on clause to wait until API is enabled
  depends_on = [
    google_project_service.iam_api
  ]
}

resource "google_cloud_scheduler_job" "default" {
  name             = "scheduled-cloud-run-job"
  description      = "Invoke a Cloud Run container on a schedule."
  schedule         = "*/8 * * * *"
  time_zone        = "America/New_York"
  attempt_deadline = "320s"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "POST"
    uri         = google_cloud_run_service.default.status[0].url

    oidc_token {
      service_account_email = google_service_account.default.email
    }
  }

  # Use an explicit depends_on clause to wait until API is enabled
  depends_on = [
    google_project_service.scheduler_api
  ]
}

resource "google_cloud_run_service_iam_member" "default" {
  project = "my-project-name"
  location = google_cloud_run_service.default.location
  service = google_cloud_run_service.default.name
  role = "roles/run.invoker"
  member = "serviceAccount:${google_service_account.default.email}"
}
# [END cloudrun_service_scheduled]
