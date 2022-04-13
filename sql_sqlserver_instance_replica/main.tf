# [START cloud_sql_sqlserver_instance_primary]
resource "google_sql_database_instance" "primary" {
  name             = "sqlserver-primary-instance-name"
  region           = "europe-west4"
  database_version = "SQLSERVER_2019_ENTERPRISE"
  root_password    = "INSERT-PASSWORD-HERE"
  settings {
    tier = "db-custom-2-7680"
    backup_configuration {
      enabled = "true"
    }
  }
  deletion_protection = "true"
}
# [END cloud_sql_sqlserver_instance_primary]

# [START cloud_sql_sqlserver_instance_replica]
resource "google_sql_database_instance" "read_replica" {
  name                 = "sqlserver-replica-instance-name"
  master_instance_name = google_sql_database_instance.primary.name
  region               = "europe-west4"
  database_version     = "SQLSERVER_2019_ENTERPRISE"
  root_password        = "INSERT-PASSWORD-HERE"
  replica_configuration {
    failover_target = false
  }

  settings {
    tier              = "db-custom-2-7680"
    availability_type = "ZONAL"
    disk_size         = "100"
  }
  deletion_protection = "true"
}
# [END cloud_sql_sqlserver_instance_replica]
