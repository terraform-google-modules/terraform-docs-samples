# [START cloud_sql_mysql_instance_backup_retention]
resource "google_sql_database_instance" "default" {
  name             = "mysql-instance-backup-retention"
  region           = "asia-northeast1"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-f1-micro"
    backup_configuration {
      enabled                        = true
      backup_retention_settings {
        retained_backups               = 365
        retention_unit                 = "COUNT"
      }
    }
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_mysql_instance_backup_retention]
