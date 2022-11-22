# Configuring Steampipe for your AWS Organization(s)

This directory contains scripts to configure the aws config file (typically `~/.aws/config`) and the Steampipe connections file (typically `~/.steampipe/config/aws.spc`) to support querying across all the AWS accounts in your AWS organization.


## Creating your AWS Config and Steampipe SPC files

There are 4 ways to configure Steampipe to query your entire AWS Organization.
1. Leverage AWS SSO (now known as AWS Identity Center) for every connection.
2. Leverage AWS SSO to authentication to one AWS account, then leverage a cross-account role from that account to all the other accounts.
3. Leverage an EC2 Instance with a Instance role in one account, then leverage a cross-account role from that account to all the other accounts.
4. Leverage a cross-account role

In each scenario, the Steampipe spc file will look like this:

```hcl
# Create an aggregator of _all_ the accounts as the first entry in the search path.
connection "aws" {
  plugin = "aws"
  type = "aggregator"
  connections = ["aws_*"]
}

connection "aws_fooli_sandbox" {
  plugin  = "aws"
  profile = "fooli-sandbox"
  regions = ["*"]
}

connection "aws_fooli_payer" {
  plugin  = "aws"
  profile = "fooli-payer"
  regions = ["*"]
}
```

### AWS SSO (for local workstation)

In this scenario, we need to authenticate to AWS SSO, then get a list of the AWS Accounts and AWS SSO roles available to the user.

We can build the `aws.spc` connection file and the AWS configuration file with the list of accounts and roles the user is authorized to access. This is what you should see when executing the script:

```bash
./generate_config_for_sso.sh fooli security-audit ~/.steampipe/config/aws.spc ~/.aws/fooli-config
https://device.sso.us-east-1.amazonaws.com/?user_code=HVWL-TLBX was opened in your browser. Please click allow.
Press Enter when complete

Creating Steampipe Connections in /Users/chris/.steampipe/config/aws.spc and AWS Profiles in /Users/chris/.aws/fooli-config
````

The resulting AWS Config file will look like this:
```
[profile fooli-dev]
sso_start_url = https://fooli.awsapps.com/start
sso_region = us-east-1
sso_account_id = 111111111111
sso_role_name = security-audit

[profile fooli-security]
sso_start_url = https://fooli.awsapps.com/start
sso_region = us-east-1
sso_account_id = 222222222222
sso_role_name = security-audit

[profile fooli-memefactory]
sso_start_url = https://fooli.awsapps.com/start
sso_region = us-east-1
sso_account_id = 333333333333
sso_role_name = security-audit
```

You can either merge this file into your existing `~/.aws/config` file, or set the `AWS_CONFIG_FILE` environment variable to the file that's created from above.

### Local Authentication with a cross-account role

In this scenario, you're still running from a local workstation and using your existing authentication methods to the trusted security account. This could be an IAM User; temporary credentials provided by [aws-gimme-creds](https://github.com/Nike-Inc/gimme-aws-creds) or AWS SSO.  All other connections will leverage a cross-account audit role. This [sample script](FIXME/generate_config_for_sso.sh) will generate an AWS config file that can be _included_ in your `~/.aws/config`. It will also generate the `aws.spc` file with all of the AWS accounts and a default aggregator.

The usage for the script is as follows:

```
Usage: ./generate_config_for_cross_account_roles.sh [IMDS | SSO ] <AUDITROLE> <AWS_CONFIG_FILE> <SSO_PROFILE>
```

Note: this script will not append or overwrite the default `~/.aws/config` file. While we try and prevent conflicts by prefixing all the profiles with `sp_`, you will want to reconcile what is generated with the other profiles in your  `~/.aws/config` file or the aws CLI will fail to run.

When merged, your aws config file should look like this:

```
[default]
signature_version=s3v4
output=json
cli_history=enabled
region=us-east-1
cli_pager=

[profile fooli-security]
sso_start_url = https://fooli.awsapps.com/start
sso_region = us-east-1
sso_account_id = 222222222222
sso_role_name = AdministratorAccess
region = us-east-1

# <other pre-existing profiles>

[profile sp_fooli-payer]
role_arn = arn:aws:iam::444444444444:role/fooli-audit
source_profile = fooli-security
role_session_name = steampipe

[profile sp_fooli-sandbox]
role_arn = arn:aws:iam::555555555555:role/fooli-audit
source_profile = fooli-security
role_session_name = steampipe

[profile sp_fooli-security]
role_arn = arn:aws:iam::222222222222:role/fooli-audit
source_profile = fooli-security
role_session_name = steampipe
```

And the resulting aws.spc file will look like this:

```hcl
# Automatically Generated at Thu Oct 20 16:26:19 EDT 2022

# Create an aggregator of _all_ the accounts as the first entry in the search path.
connection "aws" {
  plugin = "aws"
  type        = "aggregator"
  connections = ["aws_*"]
}

connection "aws_fooli_payer" {
  plugin  = "aws"
  profile = "sp_fooli-payer"
  regions = ["*"]
}

connection "aws_fooli_sandbox" {
  plugin  = "aws"
  profile = "sp_fooli-sandbox"
  regions = ["*"]
}

connection "aws_fooli_security" {
  plugin  = "aws"
  profile = "sp_fooli-security"
  regions = ["*"]
}
```


### EC2 Instance

With an EC2 Instance running Steampipe, we can leverage the [EC2 Instance Metadata Service](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html)(IMDS) to generate temporary credentials from the [Instance Profile](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html). As in the previous example, the [sample script](FIXME/generate_config_for_cross_account_roles.sh) will generate an AWS Config file and an aws.spc file. The aws.spc file will be the same as the other scenarios.

```bash
./generate_config_for_cross_account_roles.sh IMDS fooli-audit fooli-config
```

The AWS config file will contain an entry for every account in the AWS Organization. Those entries will all look like:

```
[profile sp_fooli-memefactory]
role_arn = arn:aws:iam::333333333333:role/fooli-audit
credential_source = Ec2InstanceMetadata
role_session_name = steampipe
```

Note that we use `credential_source=Ec2InstanceMetadata` rather than `source_profile`.

Here we tell the Plugin to use the EC2 Instance Metadata credentials to assume to `fooli-audit` role in the `102225541131` account, and use `steampipe` as the [RoleSessionName](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html#:~:text=RoleSessionName,assumed%20role%20session.). Because there is no dependency on a pre-configured `~/.aws/config` file, we can confidently overwrite the config files on each execution of the script. This would be safe to run as a cron job every few hours like so:

```bash
 ./generate_config_for_cross_account_roles.sh IMDS fooli-audit ~/.aws/config
 ```

## Extending this pattern to multiple AWS Organizations.

At some point, you will find yourself with a second AWS organization. Maybe you created a new organization to test Service Control Policies. Or you've acquired another company and can't migrate accounts until your legal department, and AWS's legal department agree to update terms or adjust spending commitments.

How can you leverage the above patterns across multiple AWS Organizations? We can adjust our pattern above slightly. You'll need to ensure all the accounts in each organization have the same cross-account role that trusts the same centralized security account.

Since we have to do an assume-role to get the account list from each organizations, this [sample script](FIXME/generate_config_for_multipayer.py) is in python. The usage is:

```bash
usage: generate_config_for_multipayer.py [-h] [--debug]
                                         [--aws-config-file AWS_CONFIG_FILE]
                                         [--steampipe-connection-file STEAMPIPE_CONNECTION_FILE]
                                         --rolename ROLENAME
                                         --payers PAYERS [PAYERS ...]
                                         [--role-session-name ROLE_SESSION_NAME]
```

The configuration files from that script look like the previous example, except we've added a new aggregator for the payers like so:

```hcl
connection "aws_payer" {
  plugin = "aws"
  type = "aggregator"
  regions = ["us-east-1"] # This aggregator is only used for global queries
  connections = ["aws_fooli_payer", "aws_pht_payer"]
}
```

This script is also idempotent - you can run it regularly and it will safely overwrite the existing configuration files like so:
```bash
generate_config_for_multipayer.py --aws-config-file ~/.aws/config \
                 --steampipe-connection-file ~/.steampipe/config/aws.spc \
                 --rolename fooli-audit \
                 --payers 123456789012 210987654321 \
                 --role-session-name steampipe
```

