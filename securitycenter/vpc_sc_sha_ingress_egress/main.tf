/**
 * Copyright 2026 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# [START securitycenter_vpc_sc_sha_ingress_egress]
resource "google_access_context_manager_service_perimeter_ingress_policy" "scc_sha_ingress" {
  perimeter = "accessPolicies/POLICY_ID/servicePerimeters/PERIMETER_NAME"

  ingress_from {
    identities = [
      "serviceAccount:<REDACTED_PII>"
    ]
    sources {
      access_level = "*"
    }
  }

  ingress_to {
    resources = [
      "projects/PROJECT_ID"
    ]
    # Add operations for each service SHA scans (e.g., compute, storage, bigquery)
    operations {
      service_name = "compute.googleapis.com"
      method_selectors {
        method = "*"
      }
    }
    operations {
      service_name = "storage.googleapis.com"
      method_selectors {
        method = "*"
      }
    }
  }
}

resource "google_access_context_manager_service_perimeter_egress_policy" "scc_sha_egress" {
  perimeter = "accessPolicies/POLICY_ID/servicePerimeters/PERIMETER_NAME"

  egress_from {
    identities = [
      "serviceAccount:<REDACTED_PII>"
    ]
  }

  egress_to {
    resources = [
      "projects/PROJECT_ID"
    ]
    operations {
      service_name = "compute.googleapis.com"
      method_selectors {
        method = "*"
      }
    }
    operations {
      service_name = "storage.googleapis.com"
      method_selectors {
        method = "*"
      }
    }
  }
}
# [END securitycenter_vpc_sc_sha_ingress_egress]
