terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    # ADDED: Provider for the null_resource used for polling
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

variable "trigger_dr_restore" {
  type        = bool
  description = "Set to true to trigger the DR restore API call."
  default     = false
}

variable "gcp_access_token" {
  type        = string
  description = "A valid GCP access token."
  default     = "" # Provide a default to avoid errors when trigger_dr_restore is false
}

variable "consumer_project_id" {
  type        = string
  description = "Consumer project ID"
  default     = "kavishgupta-consumer-18"
}

variable "location" {
  type        = string
  description = "GCP region for the BackupDR service"
  default     = "asia-northeast1"
}

variable "target_zone" {
  type        = string
  description = "Target zone for the restored instance"
  default     = "asia-northeast1-c"
}

variable "restored_vm_name" {
  type        = string
  description = "Name for the restored VM"
  default     = "instance-11-restrd"
}

variable "backup_vault" {
  type        = string
  default     = "bv1"
}

variable "data_source" {
  type        = string
  default     = "ds1"
}

variable "backup_id" {
  type        = string
  default     = "b1"
}

variable "restore_network" {
  type        = string
  default     = "projects/kavishgupta-consumer-18/global/networks/test-restore"
}

variable "restore_subnetwork" {
  type        = string
  default     = "projects/kavishgupta-consumer-18/regions/asia-northeast1/subnetworks/test-subnet"
}

variable "service_account_email" {
  type        = string
  default     = "<REDACTED_EMAIL>"
}

locals {
  api_endpoint = "https://backupdr.googleapis.com" # Base endpoint without version
  restore_url  = "${local.api_endpoint}/v1/projects/${var.consumer_project_id}/locations/${var.location}/backupVaults/${var.backup_vault}/dataSources/${var.data_source}/backups/${var.backup_id}:restore"

  request_body = jsonencode({
    compute_instance_target_environment = {
      project = "nkuravi-cons-1"
      zone    = var.target_zone
    }
    compute_instance_restore_properties = {
      name               = var.restored_vm_name
      network_interfaces = [
        {
          network    = var.restore_network
          subnetwork = var.restore_subnetwork
        }
      ]
      service_accounts = [
        {
          email = var.service_account_email
        }
      ]
    }
  })
}

# Step 1: Trigger the initial restore operation
data "http" "gcbdr_restore" {
  count = var.trigger_dr_restore ? 1 : 0

  url    = local.restore_url
  method = "POST"

  request_headers = {
    "Authorization" = "Bearer ${var.gcp_access_token}"
    "Content-Type"  = "application/json"
    "X-Goog-User-Project" = var.consumer_project_id
  }

  request_body = local.request_body
}

# --------------------------------------------------------------------------
# --- APPENDED SCRIPT TO POLL THE OPERATION ---
# --------------------------------------------------------------------------

# Step 2: Poll the operation until it is 'done' using a local-exec provisioner
# Step 2: Poll the operation until it is 'done' using a local-exec provisioner
resource "null_resource" "poll_restore_operation" {
  count = var.trigger_dr_restore ? 1 : 0

  # This trigger ensures the provisioner runs only when a new operation is created
  triggers = {
    operation_body = data.http.gcbdr_restore[0].response_body
  }

provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]

    command = <<-EOT
      set -e
      OPERATION_NAME=$(echo '${self.triggers.operation_body}' | jq -r '.name')
      if [ -z "$OPERATION_NAME" ] || [ "$OPERATION_NAME" == "null" ]; then
        echo "Error: Could not parse operation name from response."
        echo '${self.triggers.operation_body}'
        exit 1
      fi

      OPERATION_URL="https://backupdr.googleapis.com/v1/$OPERATION_NAME"
      echo "Polling operation at: $OPERATION_URL"

      for i in {1..40}; do
        RESPONSE=$$(curl --fail -s -H "Authorization: Bearer '${var.gcp_access_token}'" "$${OPERATION_URL}")
        DONE_STATUS=$$(echo "$${RESPONSE}" | jq -r '.done')
        echo "Attempt $$i: Polling... Operation done status is '$${DONE_STATUS}'."

        if [ "$${DONE_STATUS}" == "true" ]; then
          echo "Operation has completed."
          if echo "$${RESPONSE}" | jq -e '.error' > /dev/null; then
            echo "Final Status: FAILED"
            echo "$${RESPONSE}" | jq '.error'
            exit 1
          else
            echo "Final Status: SUCCESS"
            echo "$${RESPONSE}" > operation_result.json
            exit 0
          fi
        fi
        sleep 15
      done

      echo "Error: Operation polling timed out after 10 minutes."
      exit 1
    EOT
  }
}
# Step 3 (Optional but recommended): Read the result from the file created by the poller
data "local_file" "operation_result" {
  count = var.trigger_dr_restore ? 1 : 0

  filename = "${path.module}/operation_result.json"

  # Ensures this data source reads the file only after the polling script has finished
  depends_on = [null_resource.poll_restore_operation]
}

# --- UPDATED AND NEW OUTPUTS ---

output "final_operation_details" {
  description = "The full JSON body of the completed operation after polling."
  value       = jsondecode(data.local_file.operation_result[0].content) 
  sensitive   = true
}