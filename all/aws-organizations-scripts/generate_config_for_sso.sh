#!/bin/bash

#
# For this script, we authenticate to AWS SSO, then get a list of the AWS Accounts and AWS SSO roles available to the user.
#
# This is done via five AWS CLI commands:
# 1. `aws sso-oidc register-client` - creates a client for use in the next steps
# 2. `aws sso-oidc start-device-authorization` - manually create the redirection to the browser that you see when you
#     do the normal `aws sso login`
# 3. `aws sso-oidc create-token` - Creates the SSO Authentication token once the user has authorized the connection via
#     AWS Identity Center and their identity provider
# 4. `aws sso list-accounts` - leveraging the token from the previous command, this lists all the accounts and roles
#     the user is allowed to access in AWS Identity Center.
# 5. `aws sso list-account-roles` - list the roles available to the user for each of the accounts
#
#
# Usage:
# ./generate_config_for_sso.sh <SSO_PREFIX> <SSO_ROLE> <STEAMPIPE_CONFIG> <AWS_CONFIG> [AWS_SSO_SESSION_NAME]
#
# Example:
# ./generate_config_for_sso.sh fooli "AdministratorAccess,Billing,DataScientist" ~/.steampipe/config/aws.spc ~/.aws/fooli-config
#
# Or with a session name and a specific role:
# ./generate_config_for_sso.sh fooli security-audit ~/.steampipe/config/aws.spc ~/.aws/fooli-config "my-session-name"
#
# A session name is useful when you have multiple accounts, and with a single session login you authenticate to all accounts in that session.
#
# Note: You can specify where both the AWS and Steampipe config files will be written

set -e

SSO_PREFIX=$1
SSO_ROLES=(${2//,/ })
STEAMPIPE_CONFIG=$3
AWS_CONFIG=$4
AWS_SSO_SESSION_NAME=$5

print_usage() {
    echo "USAGE:"
    echo "  $0 <SSO_PREFIX> <SSO_ROLE> <STEAMPIPE_CONFIG> <AWS_CONFIG> [AWS_SSO_SESSION_NAME]"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 fooli \"AdministratorAccess,Billing,DataScientist\" ~/.steampipe/config/aws.spc ~/.aws/fooli-config"
    echo "  $0 fooli security-audit ~/.steampipe/config/aws.spc ~/.aws/fooli-config \"my-session-name\""
    echo ""
    echo "ARGUMENTS:"
    echo "  - SSO_PREFIX: The prefix for your AWS SSO URL. For example, if your SSO URL is https://fooli.awsapps.com, the prefix is 'fooli'."
    echo "  - SSO_ROLE: A comma-separated list of AWS SSO roles you want to generate profiles for. If you have access to 'AdministratorAccess in 2 account and 'Billing' in 4 accounts, you would specify 'AdministratorAccess,Billing'. The first role in the list will be used to determine which accounts to generate profiles for, so the order matters. If none of the accounts have the specified roles, the account will be skipped."
    echo "  - STEAMPIPE_CONFIG: The path to the Steampipe config file to write the profiles to. This file will be overwritten if it already exists."
    echo "  - AWS_CONFIG: The path to the AWS config file to write the profiles to. This file will be overwritten if it already exists."
}

if [[ $# -lt 4 ]]; then
  print_usage
  echo ""
  echo "ERROR: Missing $((4 - $#)) required argument(s)."
  exit 1
fi

START_URL="https://${SSO_PREFIX}.awsapps.com/start"
AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"

echo "Starting SSO login for $START_URL in region $AWS_DEFAULT_REGION"

aws sso-oidc register-client --client-name 'profiletool' --client-type 'public' --region "${AWS_DEFAULT_REGION}" > client.json

# Returns:
# {
#     "clientId": "REDACTED",
#     "clientSecret": "REDACTED,
#     "clientIdIssuedAt": 1667594405,
#     "clientSecretExpiresAt": 1675370405
# }

clientid=`cat client.json | jq .clientId -r`
secret=`cat client.json | jq .clientSecret -r`
rm client.json

aws sso-oidc start-device-authorization --client-id "$clientid" --client-secret "$secret" --start-url "${START_URL}" --region "${AWS_DEFAULT_REGION}" > device_auth.json

# Returns:
# {
#     "deviceCode": "REDACTED",
#     "userCode": "RHHX-BCTS",
#     "verificationUri": "https://device.sso.us-east-1.amazonaws.com/",
#     "verificationUriComplete": "https://device.sso.us-east-1.amazonaws.com/?user_code=RHHX-BCTS",
#     "expiresIn": 600,
#     "interval": 1
# }

auth_url=`cat device_auth.json | jq -r .verificationUriComplete`
devicecode=`cat device_auth.json | jq -r .deviceCode`
rm device_auth.json

# Handle WSL
if [ -e /mnt/c/Windows/System32/cmd.exe ] ; then
  if command -v wslview > /dev/null ; then
    wslview $auth_url
  else
    # Not all WSL installations have wslview, so we'll use cmd.exe
    # this will display a warning abouth the command prompt, but it's the best we can do
    /mnt/c/Windows/System32/cmd.exe /c start $auth_url
  fi
else
  open $auth_url
fi

echo "$auth_url was opened in your browser. Please click allow."
echo "Press Enter when complete"
read s

token=`aws sso-oidc create-token --client-id "$clientid" --client-secret "$secret" --grant-type 'urn:ietf:params:oauth:grant-type:device_code' --device-code "$devicecode" --region "${AWS_DEFAULT_REGION}" --query accessToken --output text`

# Returns:
# {
#     "accessToken": "REDACTED",
#     "tokenType": "Bearer",
#     "expiresIn": 14839
# }


echo "Creating Steampipe Connections in $STEAMPIPE_CONFIG and AWS Profiles in $AWS_CONFIG"
echo "# Automatically Generated at `date`" > $STEAMPIPE_CONFIG
echo "# Steampipe profiles, Automatically Generated at `date`" > $AWS_CONFIG


cat <<EOF>>$STEAMPIPE_CONFIG

# Create an aggregator of _all_ the accounts as the first entry in the search path.
connection "aws" {
  plugin = "aws"
  type        = "aggregator"
  connections = ["aws_*"]
}

EOF

# Set IFS to newline to handle account names with spaces
IFS=$'\n'

for a in `aws sso list-accounts --access-token "$token" --region "${AWS_DEFAULT_REGION}" --output json | jq -r '.accountList[] | .accountId + ":" + .accountName'`; do

  acctnum=`echo $a | awk -F: '{print $1}'`
  acctname=`echo $a | awk -F: '{print $2}' | sed s/\ /_/g` # Replace spaces with underscores

  # Steampipe doesn't like dashes, so we need to swap for underscores
  SP_NAME=`echo $acctname | sed s/-/_/g`

  available_roles=`aws sso list-account-roles --account-id "$acctnum" --access-token "$token" --region "${AWS_DEFAULT_REGION}" --output json | jq -r '.roleList[].roleName'`
  acctrole=""
  for role in ${available_roles[@]}; do
    if [[ ${SSO_ROLES[@]} =~ ${role} ]]; then
      acctrole=$role
      break
    fi
  done

  if [ -z "$acctrole" ]; then
    echo "WARNING: Skipping account $acctname ($acctnum) because it did not match any of the specified roles"
  else
      echo "Adding account $acctname ($acctnum) with role $acctrole"
      if [ -z "$AWS_SSO_SESSION_NAME" ]; then
        # Use traditional SSO method if session is not set

cat << EOF>> $AWS_CONFIG

[profile ${acctname}]
sso_start_url = ${START_URL}
sso_region = ${AWS_DEFAULT_REGION}
sso_account_id = ${acctnum}
sso_role_name = ${acctrole}
EOF

      else
        # Use SSO session if set
cat << EOF>> $AWS_CONFIG

[profile ${acctname}]
sso_session = ${AWS_SSO_SESSION_NAME}
sso_account_id = ${acctnum}
sso_role_name = ${acctrole}
EOF

      fi

    # And append an entry to the Steampipe config file
cat <<EOF>>$STEAMPIPE_CONFIG
connection "aws_${SP_NAME}" {
  plugin  = "aws"
  profile = "${acctname}"
  regions = ["*"]
}

EOF

  fi
done

