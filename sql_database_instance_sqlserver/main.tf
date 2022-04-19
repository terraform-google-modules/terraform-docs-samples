# [START cloud_sql_sqlserver_instance_80_db_n1_s2]
resource "google_sql_database_instance" "instance" {
  name             = "sqlserver-instance"
  region           = "us-central1"
  database_version = "SQLSERVER_2019_STANDARD"
  root_password = "INSERT-PASSWORD-HERE"
  settings {
    tier = "db-custom-2-7680"
  }
  deletion_protection =  "true"
}
# [END cloud_sql_sqlserver_instance_80_db_n1_s2]
