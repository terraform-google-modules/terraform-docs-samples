/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# Media CDN Docs: https://cloud.google.com/media-cdn/docs/configure-ssl-certificates

# [START mediacdn_cert_mgr_dns_auth]
resource "google_certificate_manager_dns_authorization" "default" {
  name        = "example-dns-auth"
  description = "example dns authorization "
  domain      = "test.example.com"
}
# [END mediacdn_cert_mgr_dns_auth]

# [START mediacdn_cert_mgr_dns_cert]
resource "google_certificate_manager_certificate" "default" {
  name        = "example-dns-cert"
  description = "example dns certificate"
  scope       = "EDGE_CACHE"
  managed {
    domains = [
      google_certificate_manager_dns_authorization.default.domain,
    ]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.default.id,
    ]
  }
}
# [END mediacdn_cert_mgr_dns_cert]
