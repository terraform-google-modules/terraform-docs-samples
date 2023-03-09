## Description

Fixes #<ISSUE-NUMBER>

Note: If you are not associated with Google, open an issue for discussion before submitting a pull request.

## Checklist

**Readiness**

- [ ] Yes, **merge** this PR after it is approved
- [ ] No, don't **merge** this PR after it is approved

**Style:**
  
- [ ] My sample follows the rules described for Terraform in the [Effective Samples style guide](https://googlecloudplatform.github.io/samples-style-guide/)
  
**Testing:**
  
- [ ] I have performed tests described in the [Contributing guide](https://github.com/terraform-google-modules/terraform-docs-samples/blob/main/CONTRIBUTING.md):
  
   - [ ] **Tests** pass: `terraform apply` (see [Test Environment Setup](https://github.com/terraform-google-modules/terraform-docs-samples/blob/main/CONTRIBUTING.md#set-up-the-test-environment)
   - [ ] **Lint** pass: `terraform fmt` check. See [Linting and Formatting](https://github.com/terraform-google-modules/terraform-docs-samples/blob/main/CONTRIBUTING.md#linting-and-formatting)
  
**API enablement**

- [ ] If the sample needs an API enabled to pass testing, I have added the service to the [Test setup file](https://github.com/terraform-google-modules/terraform-docs-samples/blob/main/test/setup/main.tf)

**Review**

- [ ] If this sample adds a new directory, I have added codeowners to the [CODEOWNERS file](https://github.com/terraform-google-modules/terraform-docs-samples/blob/main/.github/CODEOWNERS)
