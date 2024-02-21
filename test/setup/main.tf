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

locals {
  // Sample testing is run in parallel across num_projects.
  // Discovery and test grouping is dynamic, only this number has to be increased
  // and build/int.cloudbuild.yaml updated for new test group.
  num_projects = 4
  project_ids  = module.projects.*.project_id
}

module "projects" {
  count   = local.num_projects
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"

  name                     = "ci-tf-samples-${count.index}"
  random_project_id        = true
  random_project_id_length = 8
  org_id                   = var.org_id
  folder_id                = var.folder_id
  billing_account          = var.billing_account
  default_service_account  = "keep"
  // flask_google_cloud_quickstart, instance_virtual_display_enabled etc requires default network
  auto_create_network = true

  activate_apis = [
    "aiplatform.googleapis.com",
    "artifactregistry.googleapis.com",
    "biglake.googleapis.com",
    "bigquery.googleapis.com",
    "bigqueryconnection.googleapis.com",
    "certificatemanager.googleapis.com",
    "compute.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudscheduler.googleapis.com",
    "cloudtasks.googleapis.com",
    "container.googleapis.com",
    "dns.googleapis.com",
    "eventarc.googleapis.com",
    "iam.googleapis.com",
    "looker.googleapis.com",
    "networkconnectivity.googleapis.com",
    "networkmanagement.googleapis.com",
    "notebooks.googleapis.com",
    "privateca.googleapis.com",
    "pubsub.googleapis.com",
    "run.googleapis.com",
    "storage-api.googleapis.com",
    "servicedirectory.googleapis.com",
    "servicenetworking.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-component.googleapis.com",
    "sourcerepo.googleapis.com",
    "secretmanager.googleapis.com",
    "sqladmin.googleapis.com",
    "workflows.googleapis.com",
    "osconfig.googleapis.com",
    "connectors.googleapis.com",
    "bigqueryreservation.googleapis.com"
  ]
}
