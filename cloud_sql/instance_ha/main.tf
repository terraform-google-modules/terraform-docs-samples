/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# [START cloud_sql_mysql_instance_ha]
resource "google_sql_database_instance" "mysql_instance_ha" {
  name             = "mysql-instance-ha"
  region           = "asia-northeast1"
  database_version = "MYSQL_8_0"
  settings {
    tier              = "db-f1-micro"
    availability_type = "REGIONAL"
    backup_configuration {
      enabled            = true
      binary_log_enabled = true
      start_time         = "20:55"
    }
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}
# [END cloud_sql_mysql_instance_ha]

# [START cloud_sql_postgres_instance_ha]
resource "google_sql_database_instance" "postgres_instance_ha" {
  name             = "postgres-instance-ha"
  region           = "us-central1"
  database_version = "POSTGRES_14"
  settings {
    tier              = "db-custom-2-7680"
    availability_type = "REGIONAL"
    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "20:55"
    }
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}
# [END cloud_sql_postgres_instance_ha]

# [START cloud_sql_sqlserver_instance_ha]
resource "google_sql_database_instance" "default" {
  name             = "sqlserver-instance-ha"
  region           = "us-central1"
  database_version = "SQLSERVER_2019_STANDARD"
  root_password    = "INSERT-PASSWORD-HERE"
  settings {
    tier              = "db-custom-2-7680"
    availability_type = "REGIONAL"
    backup_configuration {
      enabled    = true
      start_time = "20:55"
    }
  }
}
# [END cloud_sql_sqlserver_instance_ha]
