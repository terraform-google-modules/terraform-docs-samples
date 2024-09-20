resource "google_integration_connectors_endpoint_attachment" "default" {
  name     = "test-endpoint-attachment"
  location = "us-central1"
  description = "tf created description"
  service_attachment = "projects/connectors-example/regions/us-central1/serviceAttachments/test"
  labels = {
    foo = "bar"
  }
}