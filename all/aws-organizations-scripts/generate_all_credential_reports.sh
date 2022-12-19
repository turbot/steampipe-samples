#!/bin/bash

if [ -z ${AWS_CONFIG_FILE+x} ] ; then
	AWS_CONFIG_FILE="~/.aws/config"
fi

PROFILES=`grep '\[profile' $AWS_CONFIG_FILE  | awk '{print $2}' | sed s/\]//g`

for p in $PROFILES ; do
	echo "Generating credential report in $p"
	aws iam generate-credential-report --profile $p --output text
done