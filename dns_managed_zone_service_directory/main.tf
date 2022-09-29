# [START dns_managed_zone_service_directory]
resource "google_dns_managed_zone" "sd-zone" {
  provider = google-beta

  name        = "peering-zone"
  dns_name    = "services.example.com."
  description = "Example private DNS Service Directory zone"

  visibility = "private"

  service_directory_config {
    namespace {
      namespace_url = google_service_directory_namespace.example.id
    }
  }
}

resource "google_service_directory_namespace" "example" {
  provider = google-beta

  namespace_id = "example"
  location     = "us-central1"
}

resource "google_compute_network" "network" {
  provider = google-beta

  name                    = "network"
  auto_create_subnetworks = false
}
# [END dns_managed_zone_service_directory]
