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

# [START vpc_ipv6_internal]
resource "google_compute_network" "default" {
  name                     = "vpc-network-ipv6"
  auto_create_subnetworks  = false
  enable_ula_internal_ipv6 = true
}
# [END vpc_ipv6_internal]

# [START vpc_subnet_dual_stack]
resource "google_compute_subnetwork" "subnet_dual_stack" {
  name             = "subnet-dual-stack"
  ip_cidr_range    = "10.0.0.0/22"
  region           = "us-west2"
  stack_type       = "IPV4_IPV6"
  ipv6_access_type = "INTERNAL"
  network          = google_compute_network.default.id
}
# [END vpc_subnet_dual_stack]

# [START vpc_subnet_ipv6_only]
resource "google_compute_subnetwork" "subnet_ipv6_only" {
  name             = "subnet-ipv6-only"
  region           = "us-central1"
  network          = google_compute_network.default.id
  stack_type       = "IPV6_ONLY"
  ipv6_access_type = "INTERNAL"
}
# [END vpc_subnet_ipv6_only]
