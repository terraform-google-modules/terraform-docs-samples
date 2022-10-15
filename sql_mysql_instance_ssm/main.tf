# [START cloud_sql_mysql_instance_ssm]
resource "google_sql_database_instance" "mysql_ssm_instance_name" {
  name                = "mysql-ssm-instance-name"
  region              = "asia-northeast1"
  database_version    = "MYSQL_5_7"
  maintenance_version = "MYSQL_5_7_38.R20220809.02_00"
  settings {
    tier = "db-f1-micro"
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_mysql_instance_ssm]
