# Cloud Run service replicated across multiple GCP regions

resource "google_project_service" "compute_api" {
  project                    = "my-project-name"
  service                    = "compute.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "run_api" {
  project                    = "my-project-name"
  service                    = "run.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = false
}

# [START cloudrun_multiregion]
variable "domain_name" {
  type    = string
  default = "example.com"
}

variable "run_regions" {
  type    = list(string)
  default = ["us-central1", "europe-west1"]
}

resource "google_compute_global_address" "lb_default" {
  name    = "myservice-service-ip"
  project = "my-project-name"

  # Use an explicit depends_on clause to wait until API is enabled
  depends_on = [
    google_project_service.compute_api
  ]
}

resource "google_compute_backend_service" "lb_default" {
  name                  = "myservice-backend"
  project               = "my-project-name"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 0.85
    group           = google_compute_region_network_endpoint_group.lb_default[0].id
  }

  backend {
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 0.85
    group           = google_compute_region_network_endpoint_group.lb_default[1].id
  }

  # Use an explicit depends_on clause to wait until API is enabled
  depends_on = [
    google_project_service.compute_api,
  ]
}


resource "google_compute_url_map" "lb_default" {
  name            = "myservice-lb-urlmap"
  project         = "my-project-name"
  default_service = google_compute_backend_service.lb_default.id

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.lb_default.id
    route_rules {
      priority = 1
      url_redirect {
        https_redirect         = true
        redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
      }
    }
  }
}

resource "google_compute_managed_ssl_certificate" "lb_default" {
  name    = "myservice-ssl-cert"
  project = "my-project-name"

  managed {
    domains = [var.domain_name]
  }
}

resource "google_compute_target_https_proxy" "lb_default" {
  name    = "myservice-https-proxy"
  project = "my-project-name"
  url_map = google_compute_url_map.lb_default.id
  ssl_certificates = [
    google_compute_managed_ssl_certificate.lb_default.name
  ]
  depends_on = [
    google_compute_managed_ssl_certificate.lb_default
  ]
}

resource "google_compute_global_forwarding_rule" "lb_default" {
  name                  = "myservice-lb-fr"
  project               = "my-project-name"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_https_proxy.lb_default.id
  ip_address            = google_compute_global_address.lb_default.id
  port_range            = "443"
  depends_on            = [google_compute_target_https_proxy.lb_default]
}

resource "google_compute_region_network_endpoint_group" "lb_default" {
  count                 = length(var.run_regions)
  project               = "my-project-name"
  name                  = "myservice-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.run_regions[count.index]
  cloud_run {
    service = google_cloud_run_service.run_default[count.index].name
  }
}

output "load_balancer_ip_addr" {
  value = google_compute_global_address.lb_default.address
}

resource "google_cloud_run_service" "run_default" {
  count    = length(var.run_regions)
  project  = "my-project-name"
  name     = "myservice-run-app-${var.run_regions[count.index]}"
  location = var.run_regions[count.index]

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  # Use an explicit depends_on clause to wait until API is enabled
  depends_on = [
    google_project_service.run_api
  ]
}

resource "google_cloud_run_service_iam_member" "run_allow_unauthenticated" {
  count    = length(var.run_regions)
  project  = "my-project-name"
  location = google_cloud_run_service.run_default[count.index].location
  service  = google_cloud_run_service.run_default[count.index].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_compute_url_map" "https_default" {
  name    = "myservice-https-urlmap"
  project = "my-project-name"

  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    https_redirect         = true
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "https_default" {
  name    = "myservice-http-proxy"
  project = "my-project-name"
  url_map = google_compute_url_map.https_default.id

  depends_on = [
    google_compute_url_map.https_default
  ]
}

resource "google_compute_global_forwarding_rule" "https_default" {
  name       = "myservice-https-fr"
  project    = "my-project-name"
  target     = google_compute_target_http_proxy.https_default.id
  ip_address = google_compute_global_address.lb_default.id
  port_range = "80"
  depends_on = [google_compute_target_http_proxy.https_default]
}
# [END cloudrun_multiregion]
