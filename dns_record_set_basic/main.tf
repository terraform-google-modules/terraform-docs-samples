# [START dns_record_set_basic]
resource "google_dns_managed_zone" "parent-zone" {
  name        = "sample-zone"
  dns_name    = "sample-zone.hashicorptest.com."
  description = "Test Description"
}

resource "google_dns_record_set" "default" {
  managed_zone = google_dns_managed_zone.parent-zone.name
  name         = "test-record.sample-zone.hashicorptest.com."
  type         = "A"
  rrdatas      = ["10.0.0.1", "10.1.0.1"]
  ttl          = 86400
}
# [END dns_record_set_basic]
