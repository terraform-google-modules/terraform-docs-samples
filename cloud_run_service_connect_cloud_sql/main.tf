# [START cloudrun_service_cloudsql_dbuser_secret]
resource "google_secret_manager_secret" "dbuser" {
  project   = "your-project-id"
  secret_id = "dbusersecret"
  replication {
    automatic = true
  }
}
# [END cloudrun_service_cloudsql_dbuser_secret]

# [START cloudrun_service_cloudsql_dbuser_secret_version]
resource "google_secret_manager_secret_version" "dbuser1" {
  secret      = google_secret_manager_secret.dbuser.id
  secret_data = "secret-data"
}
# [END cloudrun_service_cloudsql_dbuser_secret_version]

# [START cloudrun_service_cloudsql_dbpass_secret]
resource "google_secret_manager_secret" "dbpass" {
  project   = "your-project-id"
  secret_id = "dbpasssecret"
  replication {
    automatic = true
  }
}
# [END cloudrun_service_cloudsql_dbpass_secret_version]

# [START cloudrun_service_cloudsql_dbpass_secret_version]
resource "google_secret_manager_secret_version" "dbpass1" {
  secret      = google_secret_manager_secret.dbpass.id
  secret_data = "secret-data"
}
# [END cloudrun_service_cloudsql_dbpass_secret_version]

# [START cloudrun_service_cloudsql_dbname_secret]
resource "google_secret_manager_secret" "dbname" {
  project   = "your-project-id"
  secret_id = "dbnamesecret"
  replication {
    automatic = true
  }
}
# [END cloudrun_service_cloudsql_dbname_secret]

# [START cloudrun_service_cloudsql_dbname_secret_version]
resource "google_secret_manager_secret_version" "dbname1" {
  secret      = google_secret_manager_secret.dbname.id
  secret_data = "secret-data"
}
# [END cloudrun_service_cloudsql_dbname_secret_version]

# [START cloudrun_service_cloudsql_default_service]
resource "google_cloud_run_service" "default" {
  name     = "cloudrun-service"
  location = "us-central1"
  project  = "your-project-id"

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
        # Sets a environment variable for instance connection name
        env {
          name  = "INSTANCE_CONNECTION_NAME"
          value = "INSTANCE_CONNECTION_NAME_SECRET"
        }
        # Sets a secret environment variable for database user secret
        env {
          name = "DB_USER"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.dbuser.secret_id # secret name
              key  = "latest"                                      # secret version number or 'latest'
            }
          }
        }
        # Sets a secret environment variable for database password secret
        env {
          name = "DB_PASS"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.dbpass.secret_id # secret name
              key  = "latest"                                      # secret version number or 'latest'
            }
          }
        }
        # Sets a secret environment variable for database name secret
        env {
          name = "DB_NAME"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.dbname.secret_id # secret name
              key  = "latest"                                      # secret version number or 'latest'
            }
          }
        }
      }
    }
  }

  metadata {
    annotations = {
      "run.googleapis.com/client-name" = "terraform"
      # Applied only on revisions, not on initial service creation
      "autoscaling.knative.dev/maxScale" = "1000"
      # Applied only on revision, not on initial service creation
      "run.googleapis.com/cloudsql-instances" = "your-project-id:us-central1:your-cloudsql-instance-name"
    }
  }

  autogenerate_revision_name = true
}
# [END cloudrun_service_cloudsql_default_service]

