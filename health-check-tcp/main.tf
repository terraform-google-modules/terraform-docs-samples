# [START cloudloadbalancing_health_check_tcp_with_logging]
resource "google_compute_health_check" "health_check_tcp_with_logging" {
  provider = google-beta

  name = "health-check-tcp"

  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = "22"
  }

  log_config {
    enable = true
  }
}
# [END cloudloadbalancing_health_check_tcp_with_logging]
