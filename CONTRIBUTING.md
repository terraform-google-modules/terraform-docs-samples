# Contributing

This document provides guidelines for contributing to samples.

## Dependencies

The following dependencies must be installed on the development system:

- [Docker Engine][docker-engine]
- [Google Cloud SDK][google-cloud-sdk]
- [make]

Cloud Shell is recommended for development as these tools are pre-installed.

## Linting and Formatting
Files in the repository are linted or formatted to maintain a standard of quality and statically validated.
You can run this check locally:

```
cd terraform-docs-samples
make docker_test_lint
```

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

Ensure that you are locally authenticated using gcloud:

```
gcloud auth application-default login
```

With these settings in place, you can prepare a test project using Docker:

```
cd terraform-docs-samples
make docker_test_prepare
```

Sample Output:

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

project_ids = [
  "ci-tf-samples-0-c5ab",
  "ci-tf-samples-1-f344",
  "ci-tf-samples-2-b5a7",
  "ci-tf-samples-3-6eda",
]
...
```

### Noninteractive Execution

Run `make -s docker_test_sample SAMPLE=${SAMPLE_NAME}` to test a sample
noninteractively. This will initialize, apply, verify and destroy the
specified sample.

Example:
```
make -s docker_test_sample SAMPLE=storage_new_bucket
```

Sample output:

```
 make -s docker_test_sample SAMPLE=storage_new_bucket
go: downloading github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test v0.3.0
...
=== RUN   TestSamples
TestSamples terraform.go:216: Loading env vars from setup ../setup
...
2022/10/28 02:30:16 Running stage init
TestSamples/1/storage_new_bucket retry.go:91: terraform [init -upgrade=false]
...
2022/10/28 02:30:17 Running stage apply
TestSamples/1/storage_new_bucket retry.go:91: terraform [apply -input=false -auto-approve -lock=false]
...
2022/10/28 02:30:21 Running stage verify
TestSamples/1/storage_new_bucket cmd.go:103: Running terraform with args [plan -input=false -detailed-exitcode -lock=false]
...
2022/10/28 02:30:23 Running stage teardown
TestSamples/1/storage_new_bucket retry.go:91: terraform [destroy -auto-approve -input=false -lock=false]
...
TestSamples/1/storage_new_bucket command.go:185: Destroy complete! Resources: 3 destroyed.
TestSamples/1/storage_new_bucket command.go:185:
--- PASS: TestSamples (17.12s)
    --- PASS: TestSamples/1/storage_new_bucket (13.95s)
PASS
ok      github.com/terraform-google-modules/terraform-docs-samples/test/integration     17.203s
```

### Interactive Execution

Interactive execution is useful if you want to iteratively test a sample
without destroying resources automatically.

1. Run `make docker_run` to start the testing Docker container in
   interactive mode and you should see the following prompt.

    Sample output:
    ```
    [root@... workspace]#
    ```

1. Navigate to the test directory `cd test/integration`.

1. Run `RUN_STAGE=init go test -v -timeout 0 -run //${SAMPLE_NAME}` to initialize
    the sample to be tested. (Note: To reduce log verbosity, you can skip the `-v` option)

    Sample output:
    ```
    RUN_STAGE=init go test -v -timeout 0 -run //storage_new_bucket
    ...
    === RUN   TestSamples
    TestSamples 2022-10-28T02:24:48Z terraform.go:216: Loading env vars from setup ../setup
    ...
    TestSamples/1/storage_new_bucket 2022-10-28T02:24:59Z command.go:185: Success! The configuration is valid.
    TestSamples/1/storage_new_bucket 2022-10-28T02:24:59Z command.go:185:
    RUN_STAGE env var set to init
    Skipping stage apply
    RUN_STAGE env var set to init
    Skipping stage verify
    RUN_STAGE env var set to init
    Skipping stage teardown
    --- PASS: TestSamples (11.27s)
        --- PASS: TestSamples/1/storage_new_bucket (3.80s)
    ```

1. Run `RUN_STAGE=apply go test -v -timeout 0 -run //${SAMPLE_NAME}` to apply
    the sample to be tested.

    Sample output:
    ```
    RUN_STAGE=apply go test -v -timeout 0 -run //storage_new_bucket
    === RUN   TestSamples
    ...
    TestSamples/1/storage_new_bucket command.go:185: Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
    ...
    RUN_STAGE env var set to apply
    Skipping stage verify
    RUN_STAGE env var set to apply
    Skipping stage teardown
    --- PASS: TestSamples (8.70s)
        --- PASS: TestSamples/1/storage_new_bucket (5.83s)
    PASS
    ok      github.com/terraform-google-modules/terraform-docs-samples/test/integration     8.784s
    ```

1. Run `RUN_STAGE=verify go test -v -timeout 0 -run //${SAMPLE_NAME}` to verify
    the sample has been applied.

    Sample output:
    ```
    RUN_STAGE=verify go test -v -timeout 0 -run //storage_new_bucket
    === RUN   TestSamples
    ...
    TestSamples/1/storage_new_bucket  command.go:185: No changes. Your infrastructure matches the configuration.
    TestSamples/1/storage_new_bucket  command.go:185:
    TestSamples/1/storage_new_bucket  command.go:185: Terraform has compared your real infrastructure against your configuration
    TestSamples/1/storage_new_bucket  command.go:185: and found no differences, so no changes are needed.
    2022/10/28 02:27:47 RUN_STAGE env var set to verify
    2022/10/28 02:27:47 Skipping stage teardown
    --- PASS: TestSamples (6.79s)
        --- PASS: TestSamples/1/storage_new_bucket (3.93s)
    PASS
    ok      github.com/terraform-google-modules/terraform-docs-samples/test/integration     6.864s
    ```

1. Run `RUN_STAGE=teardown go test -v -timeout 0 -run //${SAMPLE_NAME}` to destroy
   resources created by the sample.

    Sample output:
    ```
    RUN_STAGE=teardown go test -v -timeout 0 -run //storage_new_bucket
    === RUN   TestSamples
    ...
    TestSamples/1/storage_new_bucket command.go:185:
    TestSamples/1/storage_new_bucket command.go:185: Destroy complete! Resources: 3 destroyed.
    TestSamples/1/storage_new_bucket command.go:185:
    --- PASS: TestSamples (8.49s)
        --- PASS: TestSamples/1/storage_new_bucket (5.65s)
    PASS
    ok      github.com/terraform-google-modules/terraform-docs-samples/test/integration     8.563s
    ```

[docker-engine]: https://www.docker.com/products/docker-engine
[google-cloud-sdk]: https://cloud.google.com/sdk/install
[make]: https://en.wikipedia.org/wiki/Make_(software)
