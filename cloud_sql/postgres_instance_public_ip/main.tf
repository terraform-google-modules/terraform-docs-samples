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

# [START cloud_sql_postgres_instance_public_ip]
resource "google_sql_database_instance" "postgres_public_ip_instance_name" {
  database_version = "POSTGRES_14"
  name             = "postgres-public-ip-instance-name"
  region           = "asia-southeast2"
  settings {
    availability_type = "ZONAL"
    ip_configuration {
      # Add optional authorized networks
      # Update to match the customer's networks
      authorized_networks {
        name  = "test-net-3"
        value = "203.0.113.0/24"
      }
      # Enable public IP
      ipv4_enabled = true
    }
    tier = "db-custom-2-7680"
  }
  # set `deletion_protection_enabled` flag to true to enable deletion protection of 
  # an instance at the GCP level. Enabling this protection will guard against 
  # accidental deletion across all surfaces (API, gcloud, Cloud Console and Terraform) 
  # by enabling the GCP Cloud SQL instance deletion protection. On the other hand, 
  # `deletion_protection` flag prevents destroy of the resource only when the deletion 
  # is attempted in terraform.
  deletion_protection = false
}
# [END cloud_sql_postgres_instance_public_ip]
