# terraform-docs-samples

Terraform samples intended for inclusion in [cloud.google.com](https://cloud.google.com/).

Typically, the samples are imported on tabs in how-to guides. For example, see
[Creating a SQL Server instance](https://cloud.google.com/compute/docs/instances/sql-server/creating-sql-server-instances#start_sql_instance).

## Setup

To run Terraform samples, the recommended approach is to use
[Cloud Shell](https://cloud.google.com/shell/docs/using-cloud-shell).

Cloud Shell is a Compute Engine virtual machine. The service credentials
associated with this virtual machine are automatic, so there is no need to
set up or download a service account key.

Terraform is integrated with Cloud Shell, and Cloud Shell automatically
authenticates Terraform, letting you get started with less setup.

1. **Activate Cloud Shell** at the top of the
   [Google Cloud Console](https://console.cloud.google.com/).

1. Clone this repository:

   git clone [https://github.com/terraform-google-modules/terraform-docs-samples.git](https://github.com/terraform-google-modules/terraform-docs-samples.git)

## How to run a sample

See [Work with a Terraform configuration](https://cloud.google.com/docs/terraform/basic-commands).

## Contributing

[Contributions](https://github.com/terraform-google-modules/terraform-docs-samples/blob/main/CONTRIBUTING.md) are welcome!

## Code style

If you are submitting or reviewing a pull request, make sure that the sample follows the
[Terraform sample guidelines](https://googlecloudplatform.github.io/samples-style-guide/) for
quality and consistency.

## Providing feedback

Open an issue in this GitHub repository.

Alternativly, from the Google Cloud documentation, click **Send feedback** near
the top right of the page or at the bottom of the page. This opens a feedback
form.
