# [START cloud_sql_mysql_instance_source]
resource "google_sql_database_instance" "source" {
  name             = "mysql-instance-source-name"
  region           = "us-central1"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-n1-standard-2"
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_mysql_instance_source]

# [START cloud_sql_mysql_instance_clone]
resource "google_sql_database_instance" "clone" {
  name             = "mysql-instance-clone-name"
  region           = "us-central1"
  database_version = "MYSQL_8_0"
  clone {
    source_instance_name = google_sql_database_instance.source.id
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_mysql_instance_clone]
