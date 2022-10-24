/**
 * Copyright 2022 Google LLC
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

# Google Cloud Documentation: https://cloud.google.com/media-cdn/docs/security-policies#creating-a-policy
# Hashicorp: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_security_policy
# In Google Cloud Console - Check in `Cloud Armor` for created policy

# [START mediacdn_create_security_policy]
resource "google_compute_security_policy" "default" {
  name        = "block-australia"
  type        = "CLOUD_ARMOR_EDGE"
  description = "block AU"

  rule {
    action      = "deny(403)"
    description = "block AU"
    priority    = "1000"
    match {
      expr {
        expression = "origin.region_code == 'AU'"
      }
    }
  }
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }
}
# [END mediacdn_create_security_policy]
