# [START cloud_sql_sqlserver_instance_backup_retention]
resource "google_sql_database_instance" "default" {
  name             = "sqlserver-instance-backup-retention"
  region           = "us-central1"
  database_version = "SQLSERVER_2019_STANDARD"
  root_password    = "INSERT-PASSWORD-HERE"
  settings {
    tier = "db-custom-2-7680"
    backup_configuration {
      enabled = true
      backup_retention_settings {
        retained_backups = 365
        retention_unit   = "COUNT"
      }
    }
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_sqlserver_instance_backup_retention]
