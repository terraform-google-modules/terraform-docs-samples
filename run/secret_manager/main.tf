
resource "google_service_account" "default" {
  account_id   = "cloud-run-service-account"
  display_name = "Service account for Cloud Run"
}

resource "google_secret_manager_secret" "default" {
  secret_id = "my-secret"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "default" {
  secret      = google_secret_manager_secret.default.name
  secret_data = "this is secret data"
}

resource "google_secret_manager_secret_iam_member" "default" {
  secret_id = google_secret_manager_secret.default.id
  role      = "roles/secretmanager.secretAccessor"
  # Grant the default Compute service account access to this secret.
  member     = "serviceAccount:${google_service_account.default.email}"
  depends_on = [google_secret_manager_secret.default]
}

resource "google_cloud_run_v2_service" "default" {
  name     = "cloudrun-srv"
  location = "us-central1"
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    volumes {
      name = "my-service-volume"
      secret {
        secret = google_secret_manager_secret.default.secret_id
        items {
          version = "latest"
          path    = "my-secret"
          mode    = 0 # use default 0444
        }
      }
    }
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      volume_mounts {
        name       = "my-service-volume"
        mount_path = "/secrets"
      }
    }
    service_account = google_service_account.default.email
  }
  depends_on = [google_secret_manager_secret_version.default]
}