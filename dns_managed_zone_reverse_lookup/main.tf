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

# Google Cloud Documentation https://cloud.google.com/dns/docs/zones/managed-reverse-lookup-zones#console

# [START dns_managed_zone_reverse_lookup]
resource "google_dns_managed_zone" "example" {
  name           = "my-new-zone"
  description    = "Example DNS reverse lookup"
  provider       = google-beta
  visibility     = "private"
  dns_name       = "2.2.20.20.in-addr.arpa."
  reverse_lookup = "true"
}
# [END dns_managed_zone_reverse_lookup]
