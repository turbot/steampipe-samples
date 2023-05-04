select
  r.name as hostname,
  type,
  jsonb_array_elements_text(records) as resource_record
from
  aws_route53_zone as z,
  aws_route53_record as r
where r.zone_id = z.id
  and (type LIKE 'A' OR type LIKE 'CNAME')
  and z.private_zone=false
  and jsonb_pretty(records) not like '%dkim%'
  and jsonb_pretty(records) not like '%acm-validations.aws.%';