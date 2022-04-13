# [START cloud_sql_sqlserver_instance_source]
resource "google_sql_database_instance" "source" {
  name             = "sqlserver-instance-source-name"
  region           = "us-central1"
  database_version = "SQLSERVER_2017_STANDARD"
  root_password = "INSERT-PASSWORD-HERE"
  settings {
    tier = "db-custom-2-7680"
  }
  deletion_protection =  "true"
}
# [END cloud_sql_sqlserver_instance_source]

# [START cloud_sql_sqlserver_instance_clone]
resource "google_sql_database_instance" "clone" {
  name             = "sqlserver-instance-clone-name"
  region           = "us-central1"
  database_version = "SQLSERVER_2017_STANDARD"
  root_password = "INSERT-PASSWORD-HERE"
  clone {
    source_instance_name = google_sql_database_instance.source.id
  }
  deletion_protection =  "true"
}
# [END cloud_sql_sqlserver_instance_clone]
