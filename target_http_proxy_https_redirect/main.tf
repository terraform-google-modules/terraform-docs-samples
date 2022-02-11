# [START cloudloadbalancing_target_http_proxy_https_redirect]
resource "google_compute_target_http_proxy" "default" {
  name    = "test-https-redirect-proxy"
  url_map = google_compute_url_map.default.id
}

resource "google_compute_url_map" "default" {
  name            = "url-map"
  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}
# [END cloudloadbalancing_target_http_proxy_https_redirect]
