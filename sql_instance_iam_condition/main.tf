data "google_project" "project" {
}

resource "google_project_service_identity" "gcp_sa_cloud_sql" {
  provider = google-beta
  service  = "sqladmin.googleapis.com"
}

# [START cloud_sql_instance_iam_conditions]
data "google_iam_policy" "sql_iam_policy" {
  binding {
    role = "roles/cloudsql.client"
    members = [
      "serviceAccount:${google_project_service_identity.gcp_sa_cloud_sql.email}",
    ]
    condition {
      expression  = "resource.name == 'projects/${data.google_project.project.id}/instances/${google_sql_database_instance.default.name}' && resource.type == 'sqladmin.googleapis.com/Instance'"
      title       = "created"
      description = "Cloud SQL instance creation"
    }
  }
}

resource "google_project_iam_policy" "project" {
  project     = data.google_project.project.id
  policy_data = data.google_iam_policy.sql_iam_policy.policy_data
}
# [END cloud_sql_instance_iam_conditions]

resource "google_sql_database_instance" "default" {
  name             = "mysql-instance-iam-condition"
  provider         = google-beta
  region           = "us-central1"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-n1-standard-2"
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
