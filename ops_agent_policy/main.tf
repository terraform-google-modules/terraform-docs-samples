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

# [START monitoring_ops_agent_policy]
module "agent_policy" {
  source     = "terraform-google-modules/cloud-operations/google//modules/agent-policy" #import the terraform agent policy module
  version    = "0.2.4"                                                                  #terraform agent policy version
  project_id = "rajas-375116"                                                           # 
  policy_id  = "ops-agents-policy-safe-rollout"                                         # define a policy name
  agent_rules = [
    #specify which policies you want to roll out
    {
      type               = "logging"
      version            = "current-major"
      package_state      = "installed"
      enable_autoupgrade = true #set to true to autoupgrade
    },
    {
      type               = "metrics"
      version            = "current-major"
      package_state      = "installed"
      enable_autoupgrade = true
    },
  ]
  group_labels = [
    #define labels to apply the ops agent policies
    {
      env = "test"
      app = "myproduct"
    }
  ]
  os_types = [
    # define the OS to apply the policy to
    {
      short_name = "centos"
      version    = "7"
    },
  ]
}
# [END monitoring_ops_agent_policy]
