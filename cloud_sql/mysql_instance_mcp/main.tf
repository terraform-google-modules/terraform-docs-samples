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

# [START cloud_sql_mysql_instance_mcp_creation]
resource "google_sql_database_instance" "mysql_mcp_creation" {
  name             = "mysql-instance-mcp-creation"
  region           = "us-central1"
  database_version = "MYSQL_8_0"

  settings {
    tier    = "db-perf-optimized-N-2"
    connection_pool_config {
      connection_pooling_enabled = true
    }
  }
}
# [END cloud_sql_mysql_instance_mcp_creation]

# [START cloud_sql_mysql_instance_mcp_enable]
# This example shows creating an instance with MCP enabled and custom flags set.
resource "google_sql_database_instance" "mysql_mcp_enable" {
  name             = "mysql-instance-mcp-enable"
  region           = "us-central1"
  database_version = "MYSQL_8_0"

  settings {
    tier    = "db-perf-optimized-N-2"
    connection_pool_config {
      connection_pooling_enabled = true
    }
  }
}
# [END cloud_sql_mysql_instance_mcp_enable]

# [START cloud_sql_mysql_instance_mcp_modify]
# This example shows modifying the flags of an existing MCP configuration.
resource "google_sql_database_instance" "mysql_mcp_modify" {
  name             = "mysql-instance-mcp-modify"
  region           = "us-central1"
  database_version = "MYSQL_8_0"

  settings {
    tier    = "db-perf-optimized-N-2"
    connection_pool_config {
      connection_pooling_enabled = true
      flags {
        name = "max_client_connections" # Modify or add the value of an flag
        value = "1980"
      }
    }
  }
}
# [END cloud_sql_mysql_instance_mcp_modify]

# [START cloud_sql_mysql_instance_mcp_disable]
# This example shows disabling MCP on an existing instance.
resource "google_sql_database_instance" "mysql_mcp_disable" {
  name             = "mysql-instance-mcp-disable"
  region           = "us-central1"
  database_version = "MYSQL_8_0"

  settings {
    tier    = "db-perf-optimized-N-2"
    connection_pool_config {
      # Set to false to disable MCP. You can also remove the block entirely.
      connection_pooling_enabled = false
    }
  }
}
# [END cloud_sql_mysql_instance_mcp_disable]

# [START cloud_sql_mysql_instance_mcp_view]
# To view the current status, you can use the `terraform show` command after applying
# your configuration. The `connection_pool_config` block will reflect the current state.
terraform show
# [END cloud_sql_mysql_instance_mcp_view]