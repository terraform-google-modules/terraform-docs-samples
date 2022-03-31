# [START cloud_sql_postgres_instance_public_ip]  
resource "google_sql_database_instance" "postgres_public_ip_instance_name" {
  database_version = "POSTGRES_12"
  name             = "postgres-public-ip-instance-name"
  region           = "asia-southeast2"
  settings {
    availability_type = "ZONAL"
    ip_configuration {
      authorized_networks {
        name  = "test-net-3"
        value = "203.0.113.0/24"
      }
      ipv4_enabled = true
    }
    tier = "db-custom-2-7680"
  }
  deletion_protection =  "true"
}
# [END cloud_sql_postgres_instance_public_ip]
