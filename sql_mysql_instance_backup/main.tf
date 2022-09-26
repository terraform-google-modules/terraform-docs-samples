# [START cloud_sql_mysql_instance_backup]
resource "google_sql_database_instance" "instance" {
  name             = "mysql-instance-backup"
  region           = "asia-northeast1"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-f1-micro"
    backup_configuration {
      enabled                        = true
      binary_log_enabled             = true
      start_time                     = "20:55"
    }
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_mysql_instance_backup]
