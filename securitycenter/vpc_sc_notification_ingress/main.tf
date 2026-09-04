/**
 * Copyright 2026 Google LLC
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

# [START securitycenter_vpc_sc_notification_ingress]
locals {
  access_policy_id    = "123456789012"
  perimeter_name      = "my_service_perimeter"
  project_number      = "123456789012"
  scc_service_account = "service-{project_number}@gcp-sa-scc-notification.iam.gserviceaccount.com"
}

resource "google_access_context_manager_service_perimeter_ingress_policy" "scc_notification_ingress" {
  perimeter = "accessPolicies/${local.access_policy_id}/servicePerimeters/${local.perimeter_name}"

  ingress_from {
    identities = [
      "serviceAccount:${local.scc_service_account}"
    ]
    sources {
      access_level = "*"
    }
  }

  ingress_to {
    resources = [
      "projects/${local.project_number}"
    ]
    operations {
      service_name = "pubsub.googleapis.com"
      method_selectors {
        # Limit to publishing messages rather than allowing topic deletion
        method = "google.pubsub.v1.Publisher.Publish"
      }
    }
  }
}
# [END securitycenter_vpc_sc_notification_ingress]

