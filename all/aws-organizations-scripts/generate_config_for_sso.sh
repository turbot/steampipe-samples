#!/bin/bash

SSO_PREFIX=$1
SSO_ROLE=$2
STEAMPIPE_CONFIG=$3
AWS_CONFIG=$4

if [ -z "$AWS_CONFIG" ] ; then
  echo "Missing SSO Prefix"
  echo "Usage: $0 <SSO_PREFIX> <SSO_ROLE> <STEAMPIPE_CONFIG> <AWS_CONFIG>"
  exit 1
fi

START_URL="https://${SSO_PREFIX}.awsapps.com/start"

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

open $auth_url

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


for a in `aws sso list-accounts --access-token "$token" --region "${AWS_DEFAULT_REGION}" --output text | awk '{print $2":"$3}'` ; do

  acctnum=`echo $a | awk -F: '{print $1}'`
  acctname=`echo $a | awk -F: '{print $2}'`

  # Steampipe doesn't like dashes, so we need to swap for underscores
  SP_NAME=`echo $acctname | sed s/-/_/g`

  aws sso list-account-roles --account-id "$acctnum" --access-token "$token" --region "${AWS_DEFAULT_REGION}" | grep $SSO_ROLE > /dev/null
  if [ $? -ne 0 ] ; then
    echo "# $SSO_ROLE was not in list of SSO roles available to this user. Skipping account $acctname ($acctnum) \n"
  else

cat << EOF>> $AWS_CONFIG

[profile ${acctname}]
sso_start_url = ${START_URL}
sso_region = ${AWS_DEFAULT_REGION}
sso_account_id = ${acctnum}
sso_role_name = ${SSO_ROLE}
EOF

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

