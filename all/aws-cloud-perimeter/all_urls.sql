select
  lower(l.protocol) || '://' || lb.dns_name || ':' || l.port as url,
  'application_load_balancer' as type
from
  aws_ec2_application_load_balancer as lb,
  aws_ec2_load_balancer_listener as l
where
  lb.scheme LIKE 'internet-facing'
  and lb.state_code LIKE 'active'
  and l.load_balancer_arn = lb.arn

UNION ALL

select
  'https://' || api_id || '.execute-api.' || region || '.amazonaws.com/' || stage_name as url,
  'api_gateway' as type
from aws_api_gatewayv2_stage

UNION ALL

select
  'https://' || domain_name as url,
  'cloudfront_distribution' as type
from
  aws_cloudfront_distribution

UNION ALL

select
  'https://' || jsonb_array_elements_text(aliases -> 'Items') as url,
  'cloudfront_distribution_alias' as type
from
  aws_cloudfront_distribution

UNION ALL

select 
  url_config ->> 'FunctionUrl' as url,
  'lambda_url' as type
from aws_lambda_function
where url_config is not Null

UNION ALL

select
  'https://' || name || '.s3.' || region || '.amazonaws.com/' as url,
  's3_bucket_url' as type
from
  aws_s3_bucket
where
  bucket_policy_is_public is True;


