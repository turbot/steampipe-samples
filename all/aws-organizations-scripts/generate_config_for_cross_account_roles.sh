#!/bin/bash

COMMAND=$1
AUDITROLE=$2
AWS_CONFIG_FILE=$3
SSO_PROFILE=$4

usage () {
  echo "Usage: $0 [IMDS | SSO ] <AUDITROLE> <AWS_CONFIG_FILE> <SSO_PROFILE>"
  exit 1
}

if [ -z "$COMMAND" ] ; then
  usage
fi

if [ $COMMAND != "IMDS" ] && [ $COMMAND != "SSO" ] ; then
  echo "Invalid Command"
  usage
fi

if [ $COMMAND == "IMDS" ] && [ -z $AWS_CONFIG_FILE ] ; then
  usage
fi

if [ $COMMAND == "SSO" ] && [ -z $SSO_PROFILE ] ; then
  usage
fi

# STEAMPIPE_INSTALL_DIR overrides the default steampipe directory of ~/.steampipe
if [ -z $STEAMPIPE_INSTALL_DIR ] ; then
  echo "STEAMPIPE_INSTALL_DIR not defined. Setting one"
  export STEAMPIPE_INSTALL_DIR=~/.steampipe
fi

if [ ! -d $STEAMPIPE_INSTALL_DIR ] ; then
  echo "STEAMPIPE_INSTALL_DIR: $STEAMPIPE_INSTALL_DIR doesn't exist. Creating it"
  mkdir -p ${STEAMPIPE_INSTALL_DIR}/config/
fi

if [ -f $AWS_CONFIG_FILE ] ; then
  echo "$AWS_CONFIG_FILE exists. Aborting rather than overwriting a critical file."
  exit 1
fi

SP_CONFIG_FILE=${STEAMPIPE_INSTALL_DIR}/config/aws.spc
ALL_REGIONS='["*"]'

echo "Creating Steampipe Connections in $SP_CONFIG_FILE and AWS Profiles in $AWS_CONFIG_FILE"
echo "# Automatically Generated at `date`" > $SP_CONFIG_FILE
echo "# Steampipe profiles, Automatically Generated at `date`" > $AWS_CONFIG_FILE

if [ $COMMAND == "IMDS" ] ; then
# Your AWS Config file needs a [default] section
cat <<EOF>>$AWS_CONFIG_FILE
[default]
region = us-east-1
EOF
fi

cat <<EOF>>$SP_CONFIG_FILE

# Create an aggregator of _all_ the accounts as the first entry in the search path.
connection "aws" {
  plugin = "aws"
  type        = "aggregator"
  connections = ["aws_*"]
}

EOF

# We now iterate across the `aws organizations list-accounts` command
while read line ; do

  # extract the values we need
  ACCOUNT_NAME=`echo $line | awk '{print $1}'`
  ACCOUNT_ID=`echo $line | awk '{print $2}'`

  # Steampipe doesn't like dashes, so we need to swap for underscores
  SP_NAME=`echo $ACCOUNT_NAME | sed s/-/_/g`

if [ $COMMAND == "IMDS" ] ; then
# Append an entry to the AWS Creds file
cat <<EOF>>$AWS_CONFIG_FILE

[profile sp_${ACCOUNT_NAME}]
role_arn = arn:aws:iam::${ACCOUNT_ID}:role/${AUDITROLE}
credential_source = Ec2InstanceMetadata
role_session_name = steampipe
EOF
else
cat <<EOF>>$AWS_CONFIG_FILE

[profile sp_${ACCOUNT_NAME}]
role_arn = arn:aws:iam::${ACCOUNT_ID}:role/${AUDITROLE}
source_profile = ${SSO_PROFILE}
role_session_name = steampipe
EOF
fi

# And append an entry to the Steampipe config file
cat <<EOF>>$SP_CONFIG_FILE
connection "aws_${SP_NAME}" {
  plugin  = "aws"
  profile = "sp_${ACCOUNT_NAME}"
  regions = ${ALL_REGIONS}
}

EOF

done < <(aws organizations list-accounts --query Accounts[].[Name,Id,Status] --output text)

if [ $COMMAND == "SSO" ] ; then
  echo "Now append $AWS_CONFIG_FILE to your active config file where $SSO_PROFILE is defined"
fi

# All done!
exit 0