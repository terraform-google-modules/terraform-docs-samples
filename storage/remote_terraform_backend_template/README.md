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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| terraform\_state\_bucket\_force\_destroy | Set this to true to enable destroying the Terraform remote state Cloud Storage bucket | `bool` | `false` | no |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
