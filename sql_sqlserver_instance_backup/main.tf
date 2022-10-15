# [START cloud_sql_sqlserver_instance_backup]
resource "google_sql_database_instance" "default" {
  name             = "sqlserver-instance-backup"
  region           = "us-central1"
  database_version = "SQLSERVER_2019_STANDARD"
  root_password    = "INSERT-PASSWORD-HERE"
  settings {
    tier = "db-custom-2-7680"
    backup_configuration {
      enabled    = true
      start_time = "20:55"
    }
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_sqlserver_instance_backup]
