/**
 * Copyright 2025 Google LLC
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

# [START cloud_sql_postgres_instance_switchover_finish]
# This sample provides the second part of the switchover operation and makes the original primary instance
# a replica of the new primary instance. After you run `terraform apply` for this sample, you'll see
# the following message:
#
# "No changes. Your infrastructure matches the configuration.
#
# Terraform has compared your real infrastructure against your configuration and found no differences, 
# so no changes are needed.
#
# Apply complete! Resources: 0 added, 0 changed, 0 destroyed."
data "google_project" "default" {
}

resource "google_sql_database_instance" "original-primary" {
  name             = "postgres-original-primary-instance"
  region           = "us-east1"
  database_version = "POSTGRES_12"
  # Change instance type for the original primary from "CLOUD_SQL_INSTANCE" to "READ_REPLICA_INSTANCE".
  instance_type = "READ_REPLICA_INSTANCE"
  # Set master_instance_name to the the new primary instance, the old DR replica.
  master_instance_name = "postgres-dr-replica-instance"
  # replica_names = [] # If you previously defined a replica_names field in your template, then delete the DR replica 
  # (new primary) from the list of replicas.  Don't delete the entire replica_names field. 
  # Instead set the field to an empty string. For example, replica_names = [""]. 

  replication_cluster {
    # This instance no longer requires a designated DR replica since it's a replica.
    # Remove the DR replica designation by setting the field to an empty string.
    failover_dr_replica_name = ""
  }

  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"
    backup_configuration {
      # Disable automated backups and PITR because this instance is now a replica.
      enabled                        = false
      point_in_time_recovery_enabled = false
    }
  }
  # Set `deletion_protection` to true to ensure that one can't accidentally
  # delete this instance by use of Terraform whereas
  # `deletion_protection_enabled` flag protects this instance at the Google Cloud level.
  deletion_protection = false
  # Optional. Add more settings.
}

resource "google_sql_database_instance" "dr-replica" {
  name             = "postgres-dr-replica-instance"
  region           = "us-west2"
  database_version = "POSTGRES_12"
  instance_type    = "CLOUD_SQL_INSTANCE"
  replica_names    = [google_sql_database_instance.original-primary.name]


  replication_cluster {
    failover_dr_replica_name = "${data.google_project.default.project_id}:${google_sql_database_instance.original-primary.name}"
  }

  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"
    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
    }
  }
  # Set `deletion_protection` to true to ensure that one can't accidentally
  # delete this instance by use of Terraform whereas
  # `deletion_protection_enabled` flag protects this instance at the Google Cloud level.
  deletion_protection = false
  # Optional. Add more settings.
}

# [END cloud_sql_postgres_instance_switchover_finish]
