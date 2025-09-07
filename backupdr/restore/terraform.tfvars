# File: dr-orchestrator/terraform.tfvars
trigger_dr_restore    = true
consumer_project_id   = "nkuravi-consumer-100"
location              = "us-central1"
target_zone           = "us-central1-c"
restored_vm_name      = "instance-11-restrd-tf-triggered" # Maybe a new name to avoid conflicts
backup_vault          = "vault-rest"
data_source           = "7308242de123e6299ebb85a41a1738f6567aa08e"
backup_id             = "da676d02-484d-4bd8-8730-46182bc2ad77"
restore_network       = "projects/nkuravi-cons-1/global/networks/test-restore"
restore_subnetwork    = "projects/nkuravi-cons-1/regions/us-central1/subnetworks/test-rest"
service_account_email = "sample@nkuravi-cons-1.iam.gserviceaccount.com" # Make sure this is a valid SA email with permissions