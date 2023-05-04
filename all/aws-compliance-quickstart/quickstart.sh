cd ~

PS3='Choose a benchmark to run: '

plugins=`steampipe plugin list`
aws_plugin="turbot/aws"
if [[ "$plugins" == *"$aws_plugin"* ]]; then
  echo "The AWS plugin is installed"
else
  echo "Installing the AWS plugin"
  steampipe plugin install aws
fi

aws_compliance_mod="steampipe-mod-aws-compliance"
if test -e $aws_compliance_mod; then
  echo "The AWS Compliance mod is installed"
else
  echo "Installing the AWS Compliance mod"
  git clone https://github.com/turbot/steampipe-mod-aws-compliance
fi

cd steampipe-mod-aws-compliance


options=(
  audit_manager_control_tower
  cis_v130
  cis_v140
  fedramp_low_rev_4
  fedramp_moderate_rev_4
  foundational_security
  gdpr
  hipaa
  nist_800_53_rev_4
  nist_csf
  pci_v321
  rbi_cyber_security
  soc_2
)

select opt in "${options[@]}"

do
  steampipe check aws_compliance.benchmark.$opt
  exit
done


