# [START cloud_sql_postgres_instance_backup_retention]
resource "google_sql_database_instance" "default" {
  name             = "postgres-instance-backup-retention"
  region           = "us-central1"
  database_version = "POSTGRES_14"
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
# [END cloud_sql_postgres_instance_backup_retention]
