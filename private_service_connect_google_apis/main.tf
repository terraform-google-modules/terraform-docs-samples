# [START vpc_subnet_private_access]
resource "google_compute_network" "network" {
  provider      = google-beta
  name          = "my-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  provider                 = google-beta
  project                  = google_compute_network.network.project
  name                     = "my-subnetwork"
  ip_cidr_range            = "10.2.0.0/16"
  region                   = "us-central1"
  network                  = google_compute_network.network.id
  private_ip_google_access = true
}
# [END vpc_subnet_private_access]

# [START compute_internal_ip_private_access]
resource "google_compute_global_address" "default" {
  provider      = google-beta
  project       = google_compute_network.network.project
  name          = "global-psconnect-ip"
  address_type  = "INTERNAL"
  purpose       = "PRIVATE_SERVICE_CONNECT"
  network       = google_compute_network.network.id
  address       = "100.100.100.106"
}
# [END compute_internal_ip_private_access]

# [START compute_forwarding_rule_private_access]
resource "google_compute_global_forwarding_rule" "default" {
  provider      = google-beta
  project       = google_compute_network.network.project
  name          = "globalrule"
  target        = "all-apis"
  network       = google_compute_network.network.id
  ip_address    = google_compute_global_address.default.id
  load_balancing_scheme = ""
}
# [END compute_forwarding_rule_private_access]
