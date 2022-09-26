# [START vpc_auto_create]
resource "google_compute_network" "vpc_network" {
  name                    = "vpc-network"
  auto_create_subnetworks = true
  mtu                     = 1460
}
# [END vpc_auto_create]
