# [START cloud_sql_postgres_instance_private_ip]

# [START vpc_postgres_instance_private_ip_network]
resource "google_compute_network" "peering_network" {
  name                    = "private-network"
  auto_create_subnetworks = "false"
}
# [END vpc_postgres_instance_private_ip_network]

# [START vpc_postgres_instance_private_ip_address]
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.peering_network.id
}
# [END vpc_postgres_instance_private_ip_address]

# [START vpc_postgres_instance_private_ip_service_connection]
resource "google_service_networking_connection" "default" {
  network                 = google_compute_network.peering_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
# [END vpc_postgres_instance_private_ip_service_connection]

# [START cloud_sql_postgres_instance_private_ip_instance]
resource "google_sql_database_instance" "default" {
  name             = "private-ip-sql-instance"
  region           = "us-central1"
  database_version = "POSTGRES_14"

  depends_on = [google_service_networking_connection.default]

  settings {
    tier = "db-custom-2-7680"
    ip_configuration {
      ipv4_enabled    = "false"
      private_network = google_compute_network.peering_network.id
    }
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}
# [END cloud_sql_postgres_instance_private_ip_instance]

# [START cloud_sql_sqlserver_instance_private_ip_routes]       
resource "google_compute_network_peering_routes_config" "peering_routes" {
  peering              = google_service_networking_connection.default.peering
  network              = google_compute_network.peering_network.name
  import_custom_routes = true
  export_custom_routes = true
}
# [END cloud_sql_sqlserver_instance_private_ip_routes]

# [START  cloud_sql_postgres_instance_private_ip_dns]
## Uncomment this block after adding a valid DNS suffix
#resource "google_service_networking_peered_dns_domain" "default" {
#  name       = "example-com"
#  network    = google_compute_network.peering_network.id
#  dns_suffix = "example.com."
#  service    = "servicenetworking.googleapis.com"
#}
# [END cloud_sql_postgres_instance_private_ip_dns]

# [END cloud_sql_postgres_instance_private_ip]
