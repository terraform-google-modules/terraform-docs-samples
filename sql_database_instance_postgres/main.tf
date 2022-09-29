# [START cloud_sql_postgres_instance_80_db_n1_s2]
resource "google_sql_database_instance" "instance" {
  name             = "postgres-instance"
  region           = "us-central1"
  database_version = "POSTGRES_14"
  settings {
    tier = "db-custom-2-7680"
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_postgres_instance_80_db_n1_s2]

# [START cloud_sql_postgres_instance_user]
resource "random_password" "pwd" {
    length = 16
    special = false
}

resource "google_sql_user" "user" {
    name = "user"
    instance = google_sql_database_instance.instance.name
    password = random_password.pwd.result
}
# [END cloud_sql_postgres_instance_user]
