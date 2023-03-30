WITH instances AS (
  SELECT
    instance_id,
    instance_type,
    account_id,
    tags ->> 'Name' AS instance_name,
    _ctx ->> 'connection_name' AS account_name,
    instance_state,
    region,
    image_id
  FROM
    aws_ec2_instance
),
org_accounts AS (
  SELECT
    id
  FROM
    aws_payer.aws_organizations_account
),
roles AS (
  SELECT
    (regexp_match(principals, ':([0-9]+):')) [ 1 ] AS foreign_account_id
  FROM
    aws_iam_role AS role,
    jsonb_array_elements(role.assume_role_policy_std -> 'Statement') AS statement,
    jsonb_array_elements_text(statement -> 'Principal' -> 'AWS') AS principals
)


SELECT DISTINCT
  aws_ec2_ami_shared.owner_id AS foreign_account_id
FROM
  instances
LEFT JOIN aws_ec2_ami_shared ON aws_ec2_ami_shared.image_id=instances.image_id
WHERE aws_ec2_ami_shared.image_owner_alias != 'amazon'
  AND aws_ec2_ami_shared.image_owner_alias != 'self'

UNION

SELECT DISTINCT
  roles.foreign_account_id AS foreign_account_id
FROM
  org_accounts
  RIGHT JOIN roles ON org_accounts.id = roles.foreign_account_id
WHERE
  org_accounts.id IS NULL