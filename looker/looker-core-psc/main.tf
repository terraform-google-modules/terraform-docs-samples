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
# [START looker_google_looker_instance_psc]
# Create an ENTERPRISE edition Looker (Google Cloud core) instance that has PSC enabled.
resource "google_looker_instance" "default" {
  name               = "my-instance"
  platform_edition   = "LOOKER_CORE_ENTERPRISE_ANNUAL"
  region             = "us-central1"
  private_ip_enabled = false
  public_ip_enabled  = false
  psc_enabled        = true
  oauth_config {
    client_id     = "my-client-id"
    client_secret = "my-client-secret"
  }
  psc_config {
    # allowed_vpcs = ["projects/{project}/global/networks/{network}"]
    # (Optional) List of VPCs that are allowed ingress into the Looker instance. Set an allowed VPC if you are creating an instance that uses only private IP.
   }
}
# [END looker_google_looker_instance_psc]
