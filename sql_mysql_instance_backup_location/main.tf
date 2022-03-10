# [START cloud_sql_mysql_instance_backup_location]
resource "google_sql_database_instance" "default" {
  name             = ""
  region           = "asia-northeast1"
  database_version = "MYSQL_5_7"
  settings {
    tier = "db-f1-micro"
    backup_configuration {
      enabled                        = true
      location                       = "asia-northeast1"
    }
  }
  deletion_protection =  "true"
}
# [END cloud_sql_mysql_instance_backup_location]
