/**
 * Copyright 2026 Google LLC
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

# [START cloud_sql_sqlserver_read_pool_auto_scale]

resource "google_sql_database_instance" "primary" {
  name             = "sqlserver-primary"
  database_version = "SQLSERVER_2019_ENTERPRISE"
  region           = "europe-west4"
  root_password    = "INSERT-PASSWORD-HERE"
  instance_type    = "CLOUD_SQL_INSTANCE"

  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
    }

    ip_configuration {
      ipv4_enabled = true
    }
  }
}

resource "google_sql_database_instance" "read_pool" {
  name                 = "sqlserver-read-pool"
  database_version     = "SQLSERVER_2019_ENTERPRISE"
  region               = "europe-west4"
  master_instance_name = google_sql_database_instance.primary.name
  instance_type        = "READ_POOL_INSTANCE"
  node_count           = 2

  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"

    ip_configuration {
      ipv4_enabled = true
    }

    read_pool_auto_scale_config {
      enabled                    = true
      min_node_count             = 2
      max_node_count             = 5
      disable_scale_in           = false
      scale_in_cooldown_seconds  = 600
      scale_out_cooldown_seconds = 600

      target_metrics {
        metric       = "AVERAGE_CPU_UTILIZATION"
        target_value = 0.5
      }
    }
  }
}

# [END cloud_sql_sqlserver_read_pool_auto_scale]
