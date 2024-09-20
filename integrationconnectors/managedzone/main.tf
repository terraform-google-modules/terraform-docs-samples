data "google_project" "target_project" {
}

resource "google_project_iam_member" "dns_peer_binding" {
  project = google_project.target_project.project_id
  role    = "roles/dns.peer"
  member  = "serviceAccount:service-${data.google_project.test_project.number}@gcp-sa-connectors.iam.gserviceaccount.com"
}

resource "google_project_service" "dns" {
  project = google_project.target_project.project_id
  service = "dns.googleapis.com"
}

resource "google_project_service" "compute" {
  project = google_project.target_project.project_id
  service = "compute.googleapis.com"
}

resource "google_compute_network" "network" {
  project = google_project.target_project.project_id
  name                    = "test"
  auto_create_subnetworks = false
  depends_on = [google_project_service.compute]
}

resource "google_dns_managed_zone" "zone" {
  name        = "test-dns"
  dns_name    = "private.example.com."
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.network.id
    }
  }
  depends_on = [google_project_service.dns]
}

data "google_project" "test_project" {
}

# [START integrationconnectors_managed_zone_example]
resource "google_integration_connectors_managed_zone" "test_managed_zone" {
  name     = "test-managed-zone"
  description = "tf created description"
  labels = {
    intent = "example"
  }
  target_project = google_project.target_project.project_id
  target_vpc = "test"
  dns = google_dns_managed_zone.zone.dns_name
  depends_on = [google_project_iam_member.dns_peer_binding,google_dns_managed_zone.zone]
}
# [END integrationconnectors_managed_zone_example]
