# [START cloudloadbalancing_url_map_bucket_and_service]
resource "google_compute_url_map" "urlmap" {
  name        = "urlmap"
  description = "a description"

  default_service = google_compute_backend_bucket.static.id

  host_rule {
    hosts        = ["mysite.com"]
    path_matcher = "mysite"
  }

  host_rule {
    hosts        = ["myothersite.com"]
    path_matcher = "otherpaths"
  }

  path_matcher {
    name            = "mysite"
    default_service = google_compute_backend_bucket.static.id

    path_rule {
      paths   = ["/home"]
      service = google_compute_backend_bucket.static.id
    }

    path_rule {
      paths   = ["/login"]
      service = google_compute_backend_service.login.id
    }

    path_rule {
      paths   = ["/static"]
      service = google_compute_backend_bucket.static.id
    }
  }

  path_matcher {
    name            = "otherpaths"
    default_service = google_compute_backend_bucket.static.id
  }

  test {
    service = google_compute_backend_bucket.static.id
    host    = "example.com"
    path    = "/home"
  }
}

resource "google_compute_backend_service" "login" {
  name        = "login"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  health_checks = [google_compute_http_health_check.default.id]
}

resource "google_compute_http_health_check" "default" {
  name               = "health-check"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}

resource "google_compute_backend_bucket" "static" {
  name        = "static-asset-backend-bucket"
  bucket_name = google_storage_bucket.static.name
  enable_cdn  = true
}

resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "static" {
  name     = "${random_id.bucket_prefix.hex}-static-asset-bucket"
  location = "US"
}
# [END cloudloadbalancing_url_map_bucket_and_service]
