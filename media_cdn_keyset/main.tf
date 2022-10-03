# Terraform Registry: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_services_edge_cache_keyset
# Google Cloud Documentation: https://cloud.google.com/media-cdn/docs/create-keyset#gcloud-cli

# [START mediacdn_edge_cache_keyset]
resource "google_network_services_edge_cache_keyset" "default" {
  name        = "prod-vod-keyset"
  description = "Keyset for prod.example.com"
  public_key {
    id    = "key-20200918"
    value = "FHsTyFHNmvNpw4o7-rp-M1yqMyBF8vXSBRkZtkQ0RKY" # Update Ed25519 public key
  }
  public_key {
    id    = "key-20200808"
    value = "Lw7LDSaDUrbDdqpPA6JEmMF5BA5GPtd7sAjvsnh7uDA=" # Update Ed25519 public key
  }
}
# [END mediacdn_edge_cache_keyset]
