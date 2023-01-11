# Copyright 2023 Google LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# [START triggering_dags_with_functions_and_pubsub]                                            
#   Triggering DAGs Using Cloud Function and Pub/Sub Messages with Terraform                                          
#                                                                                              
#   Usage:                                                                                     
#       1. Select or create a new project that you will use to create the resources                      
#       2. Replace <PROJECT_ID> with the project ID of your project
#       3. Replace <PROJECT_NUMBER> with the account number of your project
#       4. Upload into your directory the pubsub_function.zip file: https://github.com/akvelon/python-docs-samples/tree/main/composer_tutorials/triggering-dags-with-functions-and-pubsub/cloud_function
#       5. Upload into your directory the DAG source code file: https://github.com/akvelon/python-docs-samples/tree/main/composer_tutorials/triggering-dags-with-functions-and-pubsub/DAG
#       6. Set up your environment and apply the configuration using basic Terraform commands: https://cloud.google.com/docs/terraform/basic-commands
#
#   The script provisions the following resources in the project:
#  	- Creates a VPC network and a subnetwork
#	- Creates a Cloud Composer environment
#	- Creates a Composer Service Agent account
#	- Grants the Cloud Composer v2 API Service Agent Extension role and the Composer Worker role to the Composer Service Agent account
#	- Creates a new Cloud Storage bucket 
#	- Creates a new Cloud Function and deploys the function source code from the pubsub_function.zip file to the Cloud Storage bucket 
#	- Uploads the example DAG source code from the specified file into the Cloud Composer bucket

#

###############################
#                             #
# Create Composer environment #
#                             #
###############################
resource "google_composer_environment" "new_composer_env" {
  name   = "composer-environment"
  region = "us-central1"
  project = "<PROJECT_ID>"
  config {

    software_config {
      image_version = "composer-2-airflow-2"
    }
    workloads_config {
      scheduler {
        cpu        = 0.5
        memory_gb  = 1.875
        storage_gb = 1
        count      = 1
      }
      web_server {
        cpu        = 0.5
        memory_gb  = 1.875
        storage_gb = 1
      }
      worker {
        cpu = 0.5
        memory_gb  = 1.875
        storage_gb = 1
        min_count  = 1
        max_count  = 3
      }


    }
    environment_size = "ENVIRONMENT_SIZE_SMALL"

    node_config {
      network    = google_compute_network.composer_network.id
      subnetwork = google_compute_subnetwork.composer_subnetwork.id
      service_account = google_service_account.composer_env_sa.email
    }
  }
}

################################
#                              #
# Creates Networking resources #
#                              #
################################
resource "google_compute_network" "composer_network" {
  project = "<PROJECT_ID>"
  name                    = "composer-test-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "composer_subnetwork" {
  project = "<PROJECT_ID>"
  name          = "composer-test-subnet"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.composer_network.id
}

#########################
#                       #
# Creates IAM resources #
#                       #
#########################
# Comment this section to use an existing service account 
resource "google_service_account" "composer_env_sa" {
  project = "<PROJECT_ID>"
  account_id   = "composer-worker-sa"
  display_name = "Test Service Account for Composer Environment deployment "
}

resource "google_project_iam_member" "composer-worker" {
  project = "<PROJECT_ID>"
  role    = "roles/composer.worker"
  member  = "serviceAccount:${google_service_account.composer_env_sa.email}"
}

resource "google_service_account_iam_member" "custom_service_account" {
  provider = google-beta
  service_account_id = google_service_account.composer_env_sa.id
  role = "roles/composer.ServiceAgentV2Ext"
  member = "serviceAccount:service-<PROJECT_NUMBER>@cloudcomposer-accounts.iam.gserviceaccount.com"
}

########################
#                      #
# Creates PubSub topic #
#                      #
########################
resource "google_pubsub_topic" "trigger" {
  project = "<PROJECT_ID>"
  name = "dag-topic-trigger"
  message_retention_duration = "86600s"
}

##########################
#                        #
# Creates Cloud Function #
#                        #
##########################
resource "google_cloudfunctions_function" "pubsub_function" {
  project = "<PROJECT_ID>"
  name        = "pubsub-publisher"
  runtime     = "python310"
  region = "us-central1"

  available_memory_mb          = 128
  source_archive_bucket        = google_storage_bucket.cloud_function_bucket.name
  source_archive_object        = "pubsub_function.zip"
  timeout                      = 60
  entry_point                  = "pubsub_publisher"
	service_account_email				 = "<PROJECT_NUMBER>-compute@developer.gserviceaccount.com"
  trigger_http          = true

}

##################################
#                                #
# Create Cloud Storage resources #
#                                #
##################################

resource "google_storage_bucket" "cloud_function_bucket" {
  project = "<PROJECT_ID>"
  name     = "<PROJECT_ID>-cloud-function-source-code"
  location = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "cloud_function_source" {
  name   = "pubsub_function.zip"
  bucket = google_storage_bucket.cloud_function_bucket.name
  source = "./pubsub_function.zip"
}

###################
#                 #
# Upload Dag file #
#                 #
###################

resource "google_storage_bucket_object" "composer_dags_source" {
  name   = "dags/dag_pubsub_sensor.py"
  bucket = trimprefix(trimsuffix(google_composer_environment.new_composer_env.config.0.dag_gcs_prefix,"/dags"),"gs://")
  source = "./pubsub_trigger_response_dag.py"
}
# [START triggering_dags_with_functions_and_pubsub]                                            
