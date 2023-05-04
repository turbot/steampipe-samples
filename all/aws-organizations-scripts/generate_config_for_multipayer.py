#!/usr/bin/env python3

#
# This python script will leverage the supplied cross account role to list the accounts in the
# AWS Management (aka payer) accounts supplied to the --payers option.
#
# For all command line options call this script as
#   generate_config_for_multipayer.py --help
#


import sys, argparse, os
import boto3
from botocore.exceptions import ClientError
import json

def main(args):

    aws_config_file = f"""
[default]
region=us-east-1

"""

    # we need to create an aggregate of payers, by the payer names
    payer_names = []

    steampipe_connections = ""

    for payer_id in args.payers:

        accounts = list_accounts(payer_id, args)
        for a in accounts:

            sp_account_name = a['Name'].replace('-', '_')

            if a['Id'] in args.payers:
                payer_names.append(f"aws_{sp_account_name}")

            aws_config_file += f"""
# {a['Name']}
[profile {a['Name']}]
role_arn = arn:aws:iam::{a['Id']}:role/{args.rolename}
credential_source = Ec2InstanceMetadata
role_session_name = {args.role_session_name}
            """


            steampipe_connections += f"""
connection "aws_{sp_account_name}" {{
  plugin  = "aws"
  profile = "{a['Name']}"
  regions = ["*"]
    options "connection" {{
        cache     = true # true, false
        cache_ttl = 3600  # expiration (TTL) in seconds
    }}
}}
"""


    steampipe_spc_file = f"""
# Create an aggregator of _all_ the accounts as the first entry in the search path.
connection "aws" {{
  plugin = "aws"
  type = "aggregator"
  connections = ["aws_*"]
}}

connection "aws_payer" {{
  plugin = "aws"
  type = "aggregator"
  regions = ["us-east-1"] # This aggregator is only used for global queries
  connections = {json.dumps(payer_names)}
}}

{steampipe_connections}

"""

    file = open(os.path.expanduser(args.aws_config_file), "w")
    file.write(aws_config_file)
    file.close()

    file = open(os.path.expanduser(args.steampipe_connection_file), "w")
    file.write(steampipe_spc_file)
    file.close()
    exit(0)


def list_accounts(payer_id, args):
    try:

        client = boto3.client('sts')
        session = client.assume_role(RoleArn=f"arn:aws:iam::{payer_id}:role/{args.rolename}", RoleSessionName=args.role_session_name)
        creds = session['Credentials']

        org_client = boto3.client('organizations',
            aws_access_key_id = creds['AccessKeyId'],
            aws_secret_access_key = creds['SecretAccessKey'],
            aws_session_token = creds['SessionToken'],
            region_name = "us-east-1")

        output = []
        response = org_client.list_accounts(MaxResults=20)
        while 'NextToken' in response:
            output = output + response['Accounts']
            response = org_client.list_accounts(MaxResults=20, NextToken=response['NextToken'])

        output = output + response['Accounts']
        return(output)
    except ClientError as e:
        if e.response['Error']['Code'] == 'AWSOrganizationsNotInUseException':
            print("AWS Organiations is not in use or this is not a payer account")
            return(None)
        else:
            raise ClientError(e)

def do_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--debug", help="print debugging info", action='store_true')
    parser.add_argument("--aws-config-file", help="Where to write the AWS config file", default="~/.aws/config")
    parser.add_argument("--steampipe-connection-file", help="Where to write the AWS config file", default="~/.steampipe/config/aws.spc")
    parser.add_argument("--rolename", help="Role Name to Assume", required=True)
    parser.add_argument("--payers", nargs='+', help="List of Payers to configure", required=True)
    parser.add_argument("--role-session-name", help="Role Session Name to use", default="steampipe")
    args = parser.parse_args()
    return(args)

if __name__ == '__main__':
    try:
        args = do_args()
        main(args)
        exit(0)
    except KeyboardInterrupt:
        exit(1)