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