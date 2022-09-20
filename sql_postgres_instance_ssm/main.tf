# [START cloud_sql_postgres_instance_ssm]
resource "google_sql_database_instance" "postgres_ssm_instance_name" {
  name                = "postgres-ssm-instance-name"
  region              = "asia-northeast1"
  database_version    = "POSTGRES_14"
  maintenance_version = "POSTGRES_14_4.R20220710.01_07"
  settings {
    tier              = "db-f1-micro"
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_postgres_instance_ssm]
