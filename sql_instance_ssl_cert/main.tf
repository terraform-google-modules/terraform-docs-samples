# [START cloud_sql_mysql_instance_require_ssl]
resource "google_sql_database_instance" "mysql_instance" {
  name             = "mysql-instance"
  region           = "asia-northeast1"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      require_ssl = "true"
    }
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_mysql_instance_require_ssl]

# [START cloud_sql_mysql_instance_ssl_cert]
resource "google_sql_ssl_cert" "mysql_client_cert" {
  common_name = "mysql_common_name"
  instance    = google_sql_database_instance.mysql_instance.name
}
# [END cloud_sql_mysql_instance_ssl_cert]

# [START cloud_sql_postgres_instance_require_ssl]
resource "google_sql_database_instance" "postgres_instance" {
  name             = "postgres-instance"
  region           = "asia-northeast1"
  database_version = "postgres_14"
  settings {
    tier = "db-custom-2-7680"
    ip_configuration {
      require_ssl = "true"
    }
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_postgres_instance_require_ssl]

# [START cloud_sql_postgres_instance_ssl_cert]
resource "google_sql_ssl_cert" "postgres_client_cert" {
  common_name = "postgres_common_name"
  instance    = google_sql_database_instance.postgres_instance.name
}
# [END cloud_sql_postgres_instance_ssl_cert]

# [START cloud_sql_sqlserver_instance_require_ssl]
resource "google_sql_database_instance" "sqlserver_instance" {
  name             = "sqlserver-instance"
  region           = "asia-northeast1"
  database_version = "SQLSERVER_2019_STANDARD"
  root_password    = "INSERT-PASSWORD-HERE"
  settings {
    tier = "db-custom-2-7680"
    ip_configuration {
      require_ssl = "true"
    }
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_sqlserver_instance_require_ssl]
