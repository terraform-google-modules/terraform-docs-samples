# [START cloud_sql_mysql_instance_primary]
resource "google_sql_database_instance" "primary" {
  name             = "mysql-primary-instance-name"
  region           = "europe-west4"
  database_version = "MYSQL_8_0"
  settings {
    tier               = "db-n1-standard-2"
    backup_configuration {
      enabled            = "true"
      binary_log_enabled = "true"
    }
  }
  deletion_protection =  "true"
}
# [END cloud_sql_mysql_instance_primary]

# [START cloud_sql_mysql_instance_replica]
resource "google_sql_database_instance" "read_replica" {
  name                 = "mysql-replica-instance-name"
  master_instance_name = google_sql_database_instance.primary.name
  region               = "europe-west4"
  database_version     = "MYSQL_8_0"

  replica_configuration {
    failover_target = false
  }

  settings {
    tier              = "db-n1-standard-2"
    availability_type = "ZONAL"
    disk_size         = "100"
  }
  deletion_protection =  "true"
}
# [END cloud_sql_mysql_instance_replica]
