# [START cloud_sql_sqlserver_instance_flags]
resource "google_sql_database_instance" "instance" {
  name             = "sqlserver-instance"
  region           = "us-central1"
  database_version = "SQLSERVER_2019_STANDARD"
  root_password = "INSERT-PASSWORD-HERE"
  settings {
    database_flags {
      name  = "1204"
      value = "on"
    }
    database_flags {
      name  = "remote access"
      value = "on"
    }
    database_flags {
      name  = "remote query timeout (s)"
      value = "300"
    }
    tier = "db-custom-2-7680"
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_sqlserver_instance_flags]
