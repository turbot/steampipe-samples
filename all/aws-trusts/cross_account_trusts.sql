WITH org_accounts AS (
  SELECT
    id
  FROM
    payerFIXME.aws_organizations_account
),
roles AS (
  SELECT
    name,
    (regexp_match(principals, ':([0-9]+):')) [ 1 ] AS trusted_account,
    _ctx ->> 'connection_name' AS account_name
  FROM
    aws_iam_role AS role,
    jsonb_array_elements(role.assume_role_policy_std -> 'Statement') AS statement,
    jsonb_array_elements_text(statement -> 'Principal' -> 'AWS') AS principals
)
SELECT
  roles.name as role_name,
  roles.account_name,
  roles.trusted_account
FROM
  org_accounts
  RIGHT JOIN roles ON org_accounts.id = roles.trusted_account
WHERE
  org_accounts.id IS NULL