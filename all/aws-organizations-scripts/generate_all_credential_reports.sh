#!/bin/bash


#
# This script will list the profiles from the AWS config file (defined by $AWS_CONFIG_FILE) and leverage
# the profile to generate an IAM Credential report
#
# This script is useful to run ahead of any AWS Benchmark or Mod where IAM queries are made
#

if [ -z ${AWS_CONFIG_FILE+x} ] ; then
	AWS_CONFIG_FILE="~/.aws/config"
fi

PROFILES=`grep '\[profile' $AWS_CONFIG_FILE  | awk '{print $2}' | sed s/\]//g`

for p in $PROFILES ; do
	echo "Generating credential report in $p"
	aws iam generate-credential-report --profile $p --output text
done