# [START cloud_sql_mysql_instance_flags]
resource "google_sql_database_instance" "instance" {
  database_version = "MYSQL_8_0"
  name             = "mysql-instance"
  region           = "us-central1"
  settings {
    database_flags {
      name  = "general_log"
      value = "on"
    }
    database_flags {
      name  = "skip_show_database"
      value = "on"
    }
    database_flags {
      name  = "wait_timeout"
      value = "200000"
    }
    disk_type             = "PD_SSD"
    tier         = "db-n1-standard-2"
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_mysql_instance_flags]
