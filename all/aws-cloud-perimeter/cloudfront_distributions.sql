select
  'https://' || domain_name as url
from
  aws_cloudfront_distribution
UNION ALL
select
  'https://' || jsonb_array_elements_text(aliases -> 'Items') as url
from
  aws_cloudfront_distribution;