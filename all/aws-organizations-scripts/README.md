# Configuring Steampipe for your AWS Organization(s)

This directory contains scripts to configure the aws config file (typically `~/.aws/config`) and the Steampipe connections file (typically `~/.steampipe/config/aws.spc`) to support querying across all the AWS accounts in your AWS organization.

Please refer to the [documentation on steampipe.io](https://steampipe.io/docs/guides/aws-orgs).


## Scripts in this Directory:

* **[generate_all_credential_reports.sh](https://github.com/turbot/steampipe-samples/tree/main/all/aws-organizations-scripts/generate_all_credential_reports.sh)**\
  This script will iterate through your AWS_CONFIG_FILE (typically `~/.aws/confg`) and trigger the creation of an [IAM Credential Report](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_getting-report.html). This script should be run before any dashboard and benchmarks to ensure the IAM Credential report is available to the [AWS Steampipe plugin](https://hub.steampipe.io/plugins/turbot/aws).

* **[generate_config_for_cross_account_roles.sh](https://github.com/turbot/steampipe-samples/tree/main/all/aws-organizations-scripts/generate_config_for_cross_account_roles.sh)**\
  This script can be used to generate the aws config file and steampipe aws.spc files for a single AWS Organization. Usage is:
  `./generate_config_for_cross_account_roles.sh [IMDS | LOCAL ] <AUDIT_ROLE> <AWS_CONFIG_FILE> <SOURCE_PROFILE> <REGIONS>`, where:
    * `IMDS` if you're running in EC2.
    * `LOCAL` if you're running from the local machine.
    * `AUDIT_ROLE` is the name fo the [cross-account role](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html) created in all accounts.
    * `AWS_CONFIG_FILE` is where the script will output the AWS SDK profiles
    * `SOURCE_PROFILE` is only required when `LOCAL` is specified. It is the profile with the local credentials used to perform the [AssumeRole](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html) on the cross-account role.
    * `REGIONS` is only required if you need to limit your queries to specific regions (e.g. due to having the region deny control enabled in Control Tower). Format: `'["us-east-1", "eu-central-1"]'`. Defaults to `'["*"]'`.

* **[generate_config_for_multipayer.py](https://github.com/turbot/steampipe-samples/tree/main/all/aws-organizations-scripts/generate_config_for_multipayer.py)**\
  This script takes a list of AWS Management Accounts, and uses the specified `--rolename` to AssumeRole into the management account, list the child accounts, and build an AWS Config File and aws.spc file. Usage is:
  ```bash
  usage: generate_config_for_multipayer.py [-h] [--debug]
                                         [--aws-config-file AWS_CONFIG_FILE]
                                         [--steampipe-connection-file STEAMPIPE_CONNECTION_FILE]
                                         --rolename ROLENAME
                                         --payers PAYERS [PAYERS ...]
                                         [--role-session-name ROLE_SESSION_NAME]
  ```
