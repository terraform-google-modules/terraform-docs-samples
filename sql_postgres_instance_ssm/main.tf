# [START cloud_sql_mysql_instance_ssm]
resource "google_sql_database_instance" "postgres_ssm_instance_name" {
  name             = "mysql-ssm-instance-name"
  region           = "asia-northeast1"
  database_version = "POSTGRES_12"
  settings {
    tier              = "db-f1-micro"
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_postgres_instance_ssm]
