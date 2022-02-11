# [START cloudloadbalancing_target_tcp_proxy_basic]
resource "google_compute_target_tcp_proxy" "default" {
  name            = "test-proxy"
  backend_service = google_compute_backend_service.default.id
}

resource "google_compute_backend_service" "default" {
  name        = "backend-service"
  protocol    = "TCP"
  timeout_sec = 10

  health_checks = [google_compute_health_check.default.id]
}

resource "google_compute_health_check" "default" {
  name               = "health-check"
  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = "443"
  }
}
# [END cloudloadbalancing_target_tcp_proxy_basic]
