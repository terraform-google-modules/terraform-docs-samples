# [START cloud_sql_sqlserver_instance_private_ip]

# [START vpc_sqlserver_instance_private_ip_network]
resource "google_compute_network" "private_network" {
  name                    = "private-network"
  auto_create_subnetworks = "false"
}
# [END vpc_sqlserver_instance_private_ip_network]

# [START vpc_sqlserver_instance_private_ip_address]
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.private_network.id
}
# [END vpc_sqlserver_instance_private_ip_address]

# [START vpc_sqlserver_instance_private_ip_service_connection]
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.private_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
# [END vpc_sqlserver_instance_private_ip_service_connection]

# [START cloud_sql_sqlserver_instance_private_ip_instance]
resource "google_sql_database_instance" "instance" {
  name             = "private-ip-sql-instance"
  region           = "us-central1"
  database_version = "SQLSERVER_2019_STANDARD"
  root_password        = "INSERT-PASSWORD-HERE"

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-custom-2-7680"
    ip_configuration {
      ipv4_enabled    = "false"
      private_network = google_compute_network.private_network.id
    }
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_sqlserver_instance_private_ip_instance]

# [END cloud_sql_sqlserver_instance_private_ip]
