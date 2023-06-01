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

# [START cloud_sql_mysql_instance_replica_parent_tag]
# [START cloud_sql_mysql_instance_primary]
resource "google_sql_database_instance" "primary" {
  name             = "mysql-primary-instance-name"
  region           = "europe-west4"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-n1-standard-2"
    backup_configuration {
      enabled            = "true"
      binary_log_enabled = "true"
    }
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
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
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}
# [END cloud_sql_mysql_instance_replica]
# [END cloud_sql_mysql_instance_replica_parent_tag]
