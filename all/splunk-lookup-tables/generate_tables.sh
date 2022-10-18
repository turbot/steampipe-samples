#!/bin/bash

steampipe query accounts.sql --output csv > sp_aws_accounts.csv
steampipe query instances.sql --output csv > sp_ec2_instances.csv
steampipe query eni.sql --output csv > sp_eni.csv

if [ ! -z "$1" ] ; then
	SPLUNK_SERVER=$1
	scp *.csv ec2-user@$SPLUNK_SERVER:/opt/splunk/etc/system/lookups
fi
