#!/bin/bash

#
# generate_config_for_cross_account_roles.sh
#
# Iterates across a list of AWS accounts from `aws organizations list-accounts` to:
#   1. Generate a profile entry in the AWS_CONFIG_FILE specified on the command line
#   2. Append a Steampipe connection entry in the aws.spc file
#
# Note: you will need to execute this script with permissions form the AWS
# Organizations management account or any AWS account that is configured as a
# delegated administrator for an AWS Organizations service (like GuardDuty or
# IAM Access Analyzer)
#

set -e

# Initialize variables
DURATION_SECONDS=""
OU=""
EXTERNAL_ID=""

# Process flags
while getopts d:o:e: flag
do
    case "${flag}" in
        d) DURATION_SECONDS=${OPTARG};;
        o) OU=${OPTARG};;
        e) EXTERNAL_ID=${OPTARG};;
    esac
done

# Shift positional parameters
shift $((OPTIND -1))

# Now $1, $2, etc. are positional parameters
COMMAND=$1
AUDIT_ROLE=$2
AWS_CONFIG_FILE=$3
SOURCE_PROFILE=$4

usage () {
  echo "Usage: $0 [IMDS | ECS | LOCAL ] <AUDIT_ROLE> <AWS_CONFIG_FILE> <SOURCE_PROFILE> [-d DURATION_SECONDS] [-o OU] [-e EXTERNAL_ID]"
  echo "  -d DURATION_SECONDS: Optional duration in seconds for the role session"
  echo "  -o OU: Optional Organizational Unit ID to list accounts for"
  echo "  -e EXTERNAL_ID: Optional External ID to use when assuming the role"
  exit 1
}

if [ -z "$COMMAND" ] ; then
  echo "ERROR: Missing command"
  usage
fi

if [ $COMMAND != "IMDS" ] && [ $COMMAND != "ECS" ] && [ $COMMAND != "LOCAL" ] ; then
  echo "ERROR: Invalid command: $COMMAND"
  usage
fi

if ( [ $COMMAND == "IMDS" ] || [ $COMMAND == "ECS" ] ) && [ -z $AWS_CONFIG_FILE ] ; then
  echo "ERROR: AWS config file not defined"
  usage
fi

if [ -z $SOURCE_PROFILE ] ; then
  if [ $COMMAND == "LOCAL" ] ; then
    echo "ERROR: Source profile not defined"
    usage
  else
    SOURCE_PROFILE="default"
  fi
fi

# Check if OU is provided
if [ ! -z $OU ] ; then
  LIST_ACCOUNTS_COMMAND="aws organizations list-accounts-for-parent --parent-id $OU --query \"Accounts[?Status!='SUSPENDED'].[Name,Id,Status]\" --output text --profile $SOURCE_PROFILE | sort -f"
else
  LIST_ACCOUNTS_COMMAND="aws organizations list-accounts --query \"Accounts[?Status!='SUSPENDED'].[Name,Id,Status]\" --output text --profile $SOURCE_PROFILE | sort -f"
fi

# STEAMPIPE_INSTALL_DIR overrides the default steampipe directory of ~/.steampipe
if [ -z $STEAMPIPE_INSTALL_DIR ] ; then
  echo "STEAMPIPE_INSTALL_DIR not defined, using the default location"
  export STEAMPIPE_INSTALL_DIR=~/.steampipe
fi

if [ ! -d $STEAMPIPE_INSTALL_DIR ] ; then
  echo "STEAMPIPE_INSTALL_DIR: $STEAMPIPE_INSTALL_DIR doesn't exist, creating it"
  mkdir -p ${STEAMPIPE_INSTALL_DIR}/config/
fi

if [ -f $AWS_CONFIG_FILE ] ; then
  echo "$AWS_CONFIG_FILE exists, aborting rather than overwriting a critical file"
  exit 1
fi

SP_CONFIG_FILE=${STEAMPIPE_INSTALL_DIR}/config/aws.spc
ALL_REGIONS='["*"]'

echo "Generating AWS profiles in $AWS_CONFIG_FILE"
echo "# Steampipe profiles, automatically generated at `date`" > $AWS_CONFIG_FILE

echo "Appending Steampipe connections in $SP_CONFIG_FILE"
echo "# Automatically generated at `date`" >> $SP_CONFIG_FILE

if [ $COMMAND == "IMDS" ] || [ $COMMAND == "ECS" ] ; then
# Your AWS Config file needs a [default] section
cat <<EOF>>$AWS_CONFIG_FILE
[default]
region = us-east-1
EOF
fi

cat <<EOF>>$SP_CONFIG_FILE

# Create an aggregator for all accounts as the first entry in the search path.
connection "aws" {
  plugin = "aws"
  type        = "aggregator"
  connections = ["aws_*"]
}

EOF

# We now iterate across the `aws organizations list-accounts` command
while read line ; do

  # extract the values we need
  # print from first to NF-1 (except last two fields) replacing middle spaces by _
  ACCOUNT_NAME=`echo $line | awk '{for (i=1; i<NF-1; i++) printf $i " "}' | sed 's/ $//' | sed 's/ /_/g' | tr '[:upper:]' '[:lower:]'`
  ACCOUNT_ID=`echo $line | awk '{print $(NF - 1)}'`

  # Steampipe doesn't like dashes, so we need to swap for underscores
  SP_NAME=`echo $ACCOUNT_NAME | sed s/-/_/g`

if [ $ACCOUNT_NAME == "$SOURCE_PROFILE" ] ; then
  # TODO: improve how the source profile is checked
  echo "Skipping $ACCOUNT_NAME as it is the source profile"
  continue
fi

if [ $COMMAND == "IMDS" ] ; then
# Append an entry to the AWS Creds file
cat <<EOF>>$AWS_CONFIG_FILE

[profile sp_${ACCOUNT_NAME}]
role_arn = arn:aws:iam::${ACCOUNT_ID}:role/${AUDIT_ROLE}
credential_source = Ec2InstanceMetadata
role_session_name = steampipe
EOF

elif [ $COMMAND == "ECS" ] ; then
# Append an entry to the AWS Creds file
cat <<EOF>>$AWS_CONFIG_FILE

[profile sp_${ACCOUNT_NAME}]
role_arn = arn:aws:iam::${ACCOUNT_ID}:role/${AUDIT_ROLE}
credential_source = EcsContainer
role_session_name = steampipe
EOF

else

cat <<EOF>>$AWS_CONFIG_FILE

[profile sp_${ACCOUNT_NAME}]
role_arn = arn:aws:iam::${ACCOUNT_ID}:role/${AUDIT_ROLE}
source_profile = ${SOURCE_PROFILE}
role_session_name = steampipe
EOF
fi

if [ ! -z $DURATION_SECONDS ] ; then
  echo "duration_seconds = $DURATION_SECONDS" >> $AWS_CONFIG_FILE
fi

if [ ! -z $EXTERNAL_ID ] ; then
  echo "external_id = $EXTERNAL_ID" >> $AWS_CONFIG_FILE
fi

# And append an entry to the Steampipe config file
cat <<EOF>>$SP_CONFIG_FILE
connection "aws_${SP_NAME}" {
  plugin  = "aws"
  profile = "sp_${ACCOUNT_NAME}"
  regions = ${ALL_REGIONS}
}

EOF

done < <(eval $LIST_ACCOUNTS_COMMAND)

if [ $COMMAND == "LOCAL" ] ; then
  echo "Append $AWS_CONFIG_FILE to your active AWS config file where profile $SOURCE_PROFILE is defined"
  echo "Review your aws.spc file to ensure there are no conflicting connections"
fi

# All done!
exit 0
