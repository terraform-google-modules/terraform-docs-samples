# [START vpc_firewall_create]
resource "google_compute_firewall" "rules" {
  project     = "my-project-name"
  name        = "my-firewall-rule"
  network     = "default"
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol  = "tcp"
    ports     = ["80", "8080", "1000-2000"]
  }

  source_tags = ["foo"]
  target_tags = ["web"]
}
# [END vpc_firewall_create]
