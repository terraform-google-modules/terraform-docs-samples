# [START dns_managed_zone_private_peering]
resource "google_dns_managed_zone" "peering-zone" {
  name        = "peering-zone"
  dns_name    = "peering.example.com."
  description = "Example private DNS peering zone"

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.network-source.id
    }
  }

  peering_config {
    target_network {
      network_url = google_compute_network.network-target.id
    }
  }
}

resource "google_compute_network" "network-source" {
  name                    = "network-source"
  auto_create_subnetworks = false
}

resource "google_compute_network" "network-target" {
  name                    = "network-target"
  auto_create_subnetworks = false
}
# [END dns_managed_zone_private_peering]
