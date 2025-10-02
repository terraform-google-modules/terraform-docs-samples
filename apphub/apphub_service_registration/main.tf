/**
* Copyright 2025 Google LLC
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

# discovered service block
data "google_apphub_discovered_service" "cloudrun-service" {
  location    = "us-central1"
  project     = "my-project"
  service_uri = "//run.googleapis.com/projects/my-project/locations/us-central1/services/helloworld"
}

# service block
resource "google_apphub_service" "cloudrun-service" {
  location       = "global"
  project        = "management-project"
  application_id = "apphub-tutorial-global"
  service_id     = "service-id"
  attributes {
    environment {
      type = "STAGING"
    }
    criticality {
      type = "MISSION_CRITICAL"
    }
    business_owners {
      display_name = "Alice"
      email        = "alice@google.com"
    }
    developer_owners {
      display_name = "Bob"
      email        = "bob@google.com"
    }
    operator_owners {
      display_name = "Charlie"
      email        = "charlie@google.com"
    }
  }
  discovered_service = data.google_apphub_discovered_service.cloudrun-service[each.key].id
}