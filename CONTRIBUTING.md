# Contributing

This document provides guidelines for contributing to samples.

## Dependencies

The following dependencies must be installed on the development system:

- [Docker Engine][docker-engine]
- [Google Cloud SDK][google-cloud-sdk]
- [make]

## Integration Testing

Integration tests are used to verify that the samples are actuatable 
by Terraform. Tests are dynamically discovered based on directories in
repo root and executed using the [blueprint-test](https://pkg.go.dev/github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test) framework.

### Test Environment

The easiest way to test the samples are in isolated test projects. The
setup for projects are defined in [test/setup](./test/setup/)
directory.

To use this setup, you need to authenticate gcloud with an identity that has
Project Creator access on a folder and the Billing Account User role on a billing account.

Set the following environment variables.
```
export TF_VAR_org_id="your_org_id"
export TF_VAR_folder_id="your_folder_id"
export TF_VAR_billing_account="your_billing_account_id"
```

With these settings in place, you can prepare a test project using Docker:

```
cd terraform-docs-samples
make docker_test_prepare
```

### Noninteractive Execution

Run `make -s docker_test_sample SAMPLE=${SAMPLE_NAME}` to test a sample
noninteractively. This will initialize, apply, verify and destroy the
specified sample.

Example:
```
make -s docker_test_sample SAMPLE=storage_new_bucket
```

### Interactive Execution

Interactive execution is useful if you want to iteratively test a sample
without destroying resources automatically.

1. Run `make docker_run` to start the testing Docker container in
   interactive mode.

1. Navigate to the test directory `cd test/integration`.

1. Run `RUN_STAGE=init go test -v -timeout 0 -run //${SAMPLE_NAME}` to initialize
    the sample to be tested.

1. Run `RUN_STAGE=apply go test -v -timeout 0 -run //${SAMPLE_NAME}` to apply
    the sample to be tested.

1. Run `RUN_STAGE=verify go test -v -timeout 0 -run //${SAMPLE_NAME}` to verify
    the sample has been applied.

1. Run `RUN_STAGE=teardown go test -v -timeout 0 -run //${SAMPLE_NAME}` to destroy
   resources created by the sample.

[docker-engine]: https://www.docker.com/products/docker-engine
[google-cloud-sdk]: https://cloud.google.com/sdk/install
[make]: https://en.wikipedia.org/wiki/Make_(software)
