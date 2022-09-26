# [START cloud_sql_postgres_instance_source]
resource "google_sql_database_instance" "source" {
  name             = "postgres-instance-source-name"
  region           = "us-central1"
  database_version = "POSTGRES_12"
  settings {
    tier = "db-n1-standard-2"
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_postgres_instance_source]

# [START cloud_sql_postgres_instance_clone]
resource "google_sql_database_instance" "clone" {
  name             = "postgres-instance-clone-name"
  region           = "us-central1"
  database_version = "POSTGRES_12"
  clone {
    source_instance_name = google_sql_database_instance.source.id
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_postgres_instance_clone]
