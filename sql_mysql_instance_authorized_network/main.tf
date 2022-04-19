# [START cloud_sql_mysql_instance_authorized_network]
resource "google_sql_database_instance" "instance" {
  name             = "mysql-instance-with-authorized-network"
  region           = "us-central1"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      authorized_networks {
        name = "Network Name"
        value = "192.0.2.0/24"
        expiration_time = "3021-11-15T16:19:00.094Z"
      }
    }
  }
  deletion_protection =  "true"
}
# [END cloud_sql_mysql_instance_authorized_network]
