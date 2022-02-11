# [START cloud_sql_mysql_instance_80_db_n1_s2]
resource "google_sql_database_instance" "instance" {
  name             = "mysql-instance"
  region           = "us-central1"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-n1-standard-2"
  }
  deletion_protection =  "true"
}
# [END cloud_sql_mysql_instance_80_db_n1_s2]
