In this example, we show how to provision a Cloud Storage bucket and then
generate a Terraform backend configuration file.

To run this example, do the following:

 1. Initialize Terraform with a local backend:

    terraform init

 2. Provision resources and create a Cloud Storage bucket for the Terraform
    remote backend:

    terraform apply

 3. Migrate Terraform state to the remote Cloud Storage backend:

    terraform init -migrate-state
