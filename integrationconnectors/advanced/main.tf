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

data "google_project" "test_project" {
}

resource "google_secret_manager_secret" "secret-basic" {
  secret_id = "<%= ctx[:vars]['secret_id'] %>"
  replication {
    user_managed {
      replicas {
        location = "us-central1"
      }
    }
  }
}


resource "google_secret_manager_secret_version" "secret-version-basic" {
  secret      = google_secret_manager_secret.secret-basic.id
  secret_data = "dummypassword"
}

resource "google_secret_manager_secret_iam_member" "secret_iam" {
  secret_id  = google_secret_manager_secret.secret-basic.id
  role       = "roles/secretmanager.admin"
  member     = "serviceAccount:${data.google_project.test_project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret_version.secret-version-basic]
}


# [START integration_connectors_example]
resource "google_integration_connectors_connection" "testconnection" {
  name              = "test-connection"
  description       = "tf updated description"
  location          = "us-central1"
  service_account   = "${data.google_project.test_project.number}-compute@developer.gserviceaccount.com"
  connector_version = "projects/${data.google_project.test_project.project_id}/locations/global/providers/zendesk/connectors/zendesk/versions/1"
  config_variable {
    key           = "proxy_enabled"
    boolean_value = false
  }
  config_variable {
    key           = "sample_integer_value"
    integer_value = 1
  }

  config_variable {
    key = "sample_encryption_key_value"
    encryption_key_value {
      type         = "GOOGLE_MANAGED"
      kms_key_name = "sampleKMSKkey"
    }
  }

  config_variable {
    key = "sample_secret_value"
    secret_value {
      secret_version = google_secret_manager_secret_version.secret-version-basic.name
    }
  }

  suspended = false
  auth_config {
    additional_variable {
      key          = "sample_string"
      string_value = "sampleString"
    }
    additional_variable {
      key           = "sample_boolean"
      boolean_value = false
    }
    additional_variable {
      key           = "sample_integer"
      integer_value = 1
    }
    additional_variable {
      key = "sample_secret_value"
      secret_value {
        secret_version = google_secret_manager_secret_version.secret-version-basic.name
      }
    }
    additional_variable {
      key = "sample_encryption_key_value"
      encryption_key_value {
        type         = "GOOGLE_MANAGED"
        kms_key_name = "sampleKMSKkey"
      }
    }
    auth_type = "USER_PASSWORD"
    auth_key  = "sampleAuthKey"
    user_password {
      username = "user@xyz.com"
      password {
        secret_version = google_secret_manager_secret_version.secret-version-basic.name
      }
    }
  }

  destination_config {
    key = "url"
    destination {
      host = "https://test.zendesk.com"
      port = 80
    }
  }
  lock_config {
    locked = false
    reason = "Its not locked"
  }
  log_config {
    enabled = true
  }
  node_config {
    min_node_count = 2
    max_node_count = 50
  }
  labels = {
    foo = "bar"
  }
  ssl_config {
    additional_variable {
      key          = "sample_string"
      string_value = "sampleString"
    }
    additional_variable {
      key           = "sample_boolean"
      boolean_value = false
    }
    additional_variable {
      key           = "sample_integer"
      integer_value = 1
    }
    additional_variable {
      key = "sample_secret_value"
      secret_value {
        secret_version = google_secret_manager_secret_version.secret-version-basic.name
      }
    }
    additional_variable {
      key = "sample_encryption_key_value"
      encryption_key_value {
        type         = "GOOGLE_MANAGED"
        kms_key_name = "sampleKMSKkey"
      }
    }
    client_cert_type = "PEM"
    client_certificate {
      secret_version = google_secret_manager_secret_version.secret-version-basic.name
    }
    client_private_key {
      secret_version = google_secret_manager_secret_version.secret-version-basic.name
    }
    client_private_key_pass {
      secret_version = google_secret_manager_secret_version.secret-version-basic.name
    }
    private_server_certificate {
      secret_version = google_secret_manager_secret_version.secret-version-basic.name
    }
    server_cert_type = "PEM"
    trust_model      = "PRIVATE"
    type             = "TLS"
    use_ssl          = true
  }

  eventing_enablement_type = "EVENTING_AND_CONNECTION"
  eventing_config {
    additional_variable {
      key          = "sample_string"
      string_value = "sampleString"
    }
    additional_variable {
      key           = "sample_boolean"
      boolean_value = false
    }
    additional_variable {
      key           = "sample_integer"
      integer_value = 1
    }
    additional_variable {
      key = "sample_secret_value"
      secret_value {
        secret_version = google_secret_manager_secret_version.secret-version-basic.name
      }
    }
    additional_variable {
      key = "sample_encryption_key_value"
      encryption_key_value {
        type         = "GOOGLE_MANAGED"
        kms_key_name = "sampleKMSKkey"
      }
    }
    registration_destination_config {
      key = "registration_destination_config"
      destination {
        host = "https://test.zendesk.com"
        port = 80
      }
    }
    auth_config {
      auth_type = "USER_PASSWORD"
      auth_key  = "sampleAuthKey"
      user_password {
        username = "user@xyz.com"
        password {
          secret_version = google_secret_manager_secret_version.secret-version-basic.name
        }
      }
      additional_variable {
        key          = "sample_string"
        string_value = "sampleString"
      }
      additional_variable {
        key           = "sample_boolean"
        boolean_value = false
      }
      additional_variable {
        key           = "sample_integer"
        integer_value = 1
      }
      additional_variable {
        key = "sample_secret_value"
        secret_value {
          secret_version = google_secret_manager_secret_version.secret-version-basic.name
        }
      }
      additional_variable {
        key = "sample_encryption_key_value"
        encryption_key_value {
          type         = "GOOGLE_MANAGED"
          kms_key_name = "sampleKMSKkey"
        }
      }
    }
    enrichment_enabled = true
  }
}
# [END integration_connectors_example]
