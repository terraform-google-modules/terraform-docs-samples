# [START cloud_sql_sqlserver_instance_ssm]
resource "google_sql_database_instance" "sqlserver_ssm_instance_name" {
  name                = "sqlserver-ssm-instance-name"
  region              = "asia-northeast1"
  database_version    = "SQLSERVER_2019_STANDARD"
  maintenance_version = "SQLSERVER_2019_STANDARD_CU16_GDR.R20220821.00_00"
  settings {
    tier              = "db-f1-micro"
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_sqlserver_instance_ssm]