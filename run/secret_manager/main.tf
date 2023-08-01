
data "google_project" "default" {
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
  secret_id  = google_secret_manager_secret.default.id
  role       = "roles/secretmanager.secretAccessor"
  # Grant the default Compute service account access to this secret.
  member     = "serviceAccount:${data.google_project.default.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.default]
}
