# GitHub Actions + OIDC Overview

OpenID Connect (OIDC) allows your workflows to exchange short-lived tokens directly from your cloud provider.
If you are new to running GitHub Actions with OIDC, please refer to this [link](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect) for more details.

### Preface

- This is a collection of Terraform samples to get started with GitHub Actions and OIDC.

- This is designed to support the documents on integrating [Steampipe with Github Actions](https://steampipe.io/docs/integrations/github_action), but can also be used beyond the scope of this section.

- These terraform samples create an Open ID Connect provider in your cloud environment and an IAM resource(Role, Service Principle, Service account) with a **ReadOnly** access on the account in order to run Steampipe Benchmarks. You may choose to use least privilege principle.

- Add all the Terraform Outputs with prefix "OIDC\_" to GitHub secrets of your repository.
