/**
 * Copyright 2024 Google LLC
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
# [START application_integration_create_auth_config]

resource "google_integrations_client" "client" {
  location = "us-central1"
}

resource "random_id" "default" {
  byte_length = 8
}

resource "google_service_account" "default" {
  account_id   = "sa-${random_id.default.hex}"
  display_name = "Service Account"
}

resource "google_integrations_auth_config" "auth_config_auth_token" {
  location     = "us-central1"
  display_name = "tf-auth-token"
  description  = "Test auth config created via terraform"
  decrypted_credential {
    credential_type = "AUTH_TOKEN"
    auth_token {
      type  = "Basic"
      token = "some-random-token"
    }
  }
  depends_on = [google_integrations_client.client]
}

resource "google_integrations_auth_config" "auth_config_certificate" {
  location     = "us-central1"
  display_name = "tf-certificate"
  description  = "Test auth config created via terraform"
  decrypted_credential {
    credential_type = "CLIENT_CERTIFICATE_ONLY"
  }
  client_certificate {
    ssl_certificate       = <<EOT
-----BEGIN CERTIFICATE-----
MIICTTCCAbagAwIBAgIJAPT0tSKNxan/MA0GCSqGSIb3DQEBCwUAMCoxFzAVBgNV
BAoTDkdvb2dsZSBURVNUSU5HMQ8wDQYDVQQDEwZ0ZXN0Q0EwHhcNMTUwMTAxMDAw
MDAwWhcNMjUwMTAxMDAwMDAwWjAuMRcwFQYDVQQKEw5Hb29nbGUgVEVTVElORzET
MBEGA1UEAwwKam9lQGJhbmFuYTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEA
vDYFgMgxi5W488d9J7UpCInl0NXmZQpJDEHE4hvkaRlH7pnC71H0DLt0/3zATRP1
JzY2+eqBmbGl4/sgZKYv8UrLnNyQNUTsNx1iZAfPUflf5FwgVsai8BM0pUciq1NB
xD429VFcrGZNucvFLh72RuRFIKH8WUpiK/iZNFkWhZ0CAwEAAaN3MHUwDgYDVR0P
AQH/BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAMBgNVHRMB
Af8EAjAAMBkGA1UdDgQSBBCVgnFBCWgL/iwCqnGrhTPQMBsGA1UdIwQUMBKAEKey
Um2o4k2WiEVA0ldQvNYwDQYJKoZIhvcNAQELBQADgYEAYK986R4E3L1v+Q6esBtW
JrUwA9UmJRSQr0N5w3o9XzarU37/bkjOP0Fw0k/A6Vv1n3vlciYfBFaBIam1qRHr
5dMsYf4CZS6w50r7hyzqyrwDoyNxkLnd2PdcHT/sym1QmflsjEs7pejtnohO6N2H
wQW6M0H7Zt8claGRla4fKkg=
-----END CERTIFICATE-----
EOT
    encrypted_private_key = <<EOT
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCA/Oj2HXqs5fTk
j/8DrlOQtLG3K9RMsYHvnwICLxkGqVcTfut58hDFLbQM8C3C0ENAKitNJplCJmYG
8VpgZzgq8VxaGnlP/sXUFLMGksd5sATn0sY3SkPndTKk/dqqA4MIh/dYfh19ynEN
hB9Ll/h54Yic2je2Qaxe/uMMu8RODTz3oCn7FcoYpPvfygfU0ntn4IcqH/hts5DG
s+3otJk4entRZglQDxR+sWOsbLtJIQZDP8rH3jDVdl5l3wspgtMTY8b5T5+pLm0p
/OzCmxT0dq/O6BhpxI1xf/zcdRZeWk5DTJxTi5AgPquTlAG/B6A3HkqBJ14hT/Rk
iv7Ma3DLAgMBAAECggEABATkf9VfpiAT9zYdouk50bBpckvymQTyQLD8SlBaX+KY
kgv/pHSXK4Pm4iensrQerFLgfqPA3U+FiqjW5Mv7c1VRK6HJbuVkpdzoXLI9IQsL
vsBY7//9Ajk5P7NokjdB6JPdU/2dHROuQVa59cxPtzpHo0htnPlDOKXfFZZuoZ17
Nr8WQHrHy8P8ABM1tLOzvU9Nlh7TcjQvev+HxkLek4qzYyJ/Ac7XOjg/XKUm1tZk
O3BHr8YLabwyjO7l1t+2b14rUTL/8pfUZnAkEi3FAlPxm3ilftmX65zliC9G4ghk
dr5PByT3DqnuIIglua9bISv1H34ogecd+9a6EU7RxQKBgQC2RPKLounXZo8vYiU4
sFTEvjbs+u9Ypk4OrNLnb8KdacLBUaJGnf++xbBoKpwFCBJfy//fvuQfusYF9Gyn
GxL43tw94C/H5upQYnDsmnQak6TbOu3mA24OGK7Rcq6NEHgeCY4HomutnSiPTZJq
8jlpqgqh1itETe5avgkMNq3zBwKBgQC1KlztGzvbB+rUDc6Kfvk5pUbCSFKMMMa2
NWNXeD6i2iA56zEYSbTjKQ3u9pjUV8LNqAdUFxmbdPxZjheNK2dEm68SVRXPKOeB
EmQT+t/EyW9LqBEA2oZt3h2hXtK8ppJjQm4XUCDs1NphP87eNzx5FLzJWjG8VqDq
jOvApNqPHQKBgDQqlZSbgvvwUYjJOUf5R7mri0LWKwyfRHX0xsQQe43cCC6WM7Cs
Zdbu86dMkqzp+4BJfalHFDl0llp782D8Ybiy6CwZbvNyxptNIW7GYfZ9TVCllBMh
5izIqbgub4DWNtq591l+Bf2BnmstU3uiagYw8awSBP4eo9p6y1IgkDafAoGBAJbi
lIiqEP0IqA06/pWc0Qew3rD7OT0ndqjU6Es2i7xovURf3QDkinJThBZNbdYUzdsp
IgloP9yY33/a90SNLLIYlARJtyNVZxK59X4qiOpF9prlfFvgpOumfbkj15JljTB8
aGKkSvfVA5jRYwLysDwMCHwO0bOR1u3itos5AgsFAoGAKEGms1kuQ5/HyFgSmg9G
wBUzu+5Y08/A37rvyXsR6GjmlZJvULEopJNUNCOOpITNQikXK63sIFry7/59eGv5
UwKadZbfwbVF5ipu59UxfVE3lipf/mYePDqMkHVWv/8p+OnnJt9uKnyW8VSOu5uk
82QF30zbIWDTUjrcugVAs+E=
-----END PRIVATE KEY-----     
EOT
  }
  depends_on = [google_integrations_client.client]
}

resource "google_integrations_auth_config" "auth_config_jwt" {
  location     = "us-central1"
  display_name = "tf-jwt"
  description  = "Test auth config created via terraform"
  decrypted_credential {
    credential_type = "JWT"
    jwt {
      jwt_header  = "{\"alg\": \"HS256\", \"typ\": \"JWT\"}"
      jwt_payload = "{\"sub\": \"1234567890\", \"name\": \"John Doe\", \"iat\": 1516239022}"
      secret      = "secret"
    }
  }
  depends_on = [google_integrations_client.client]
}

resource "google_integrations_auth_config" "auth_config_oauth2_authorization_code" {
  location     = "us-central1"
  display_name = "tf-oauth2-authorization-code"
  description  = "Test auth config created via terraform"
  decrypted_credential {
    credential_type = "OAUTH2_AUTHORIZATION_CODE"
    oauth2_authorization_code {
      client_id      = "Kf7utRvgr95oGO5YMmhFOLo8"
      client_secret  = "D-XXFDDMLrg2deDgczzHTBwC3p16wRK1rdKuuoFdWqO0wliJ"
      scope          = "photo offline_access"
      auth_endpoint  = "https://authorization-server.com/authorize"
      token_endpoint = "https://authorization-server.com/token"
    }
  }
  depends_on = [google_integrations_client.client]
}

resource "google_integrations_auth_config" "auth_config_oauth2_client_credentials" {
  location     = "us-central1"
  display_name = "tf-oauth2-client-credentials"
  description  = "Test auth config created via terraform"
  decrypted_credential {
    credential_type = "OAUTH2_CLIENT_CREDENTIALS"
    oauth2_client_credentials {
      client_id      = "demo-backend-client"
      client_secret  = "MJlO3binatD9jk1"
      scope          = "read"
      token_endpoint = "https://login-demo.curity.io/oauth/v2/oauth-token"
      request_type   = "ENCODED_HEADER"
      token_params {
        entries {
          key {
            literal_value {
              string_value = "string-key"
            }
          }
          value {
            literal_value {
              string_value = "string-value"
            }
          }
        }
      }
    }
  }
  depends_on = [google_integrations_client.client]
}

resource "google_integrations_auth_config" "auth_config_oidc_token" {
  location     = "us-central1"
  display_name = "tf-oidc-token"
  description  = "Test auth config created via terraform"
  decrypted_credential {
    credential_type = "OIDC_TOKEN"
    oidc_token {
      service_account_email = google_service_account.default.email
      audience              = "https://us-central1-project.cloudfunctions.net/functionA 1234987819200.apps.googleusercontent.com"
    }
  }
  depends_on = [google_integrations_client.client]
}

resource "google_integrations_auth_config" "auth_config_service_account" {
  location     = "us-central1"
  display_name = "tf-service-account"
  description  = "Test auth config created via terraform"
  decrypted_credential {
    credential_type = "SERVICE_ACCOUNT"
    service_account_credentials {
      service_account = google_service_account.default.email
      scope           = "https://www.googleapis.com/auth/cloud-platform https://www.googleapis.com/auth/adexchange.buyer https://www.googleapis.com/auth/admob.readonly"
    }
  }
  depends_on = [google_integrations_client.client]
}
# [END application_integration_create_auth_config]
