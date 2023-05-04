WITH all_foreign_accounts AS (
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
),
known_aws_accounts AS (
	WITH name_data AS (
	  SELECT
	    split_part(key_path::text, '.', 1) AS id,
	    value AS name
	  FROM
	    cloudmapper.yml_key_value
	  WHERE
	    key_path::text LIKE '%.name%'
	), account_data AS (
	  SELECT
	    split_part(key_path::text, '.', 1) AS id,
	    value AS account
	  FROM
	    cloudmapper.yml_key_value
	  WHERE
	    key_path::text LIKE '%.accounts.%'
	)
	SELECT
	  n.name,
	  a.account
	FROM
	  name_data n
	JOIN
	  account_data a ON n.id = a.id
	ORDER BY
	  n.name, a.account
)
SELECT 
	all_foreign_accounts.foreign_account_id,
	known_aws_accounts.name
FROM
	all_foreign_accounts
LEFT JOIN known_aws_accounts
ON all_foreign_accounts.foreign_account_id = known_aws_accounts.account