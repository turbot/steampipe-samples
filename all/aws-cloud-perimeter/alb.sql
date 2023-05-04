select
  lower(l.protocol) || '://' || lb.dns_name || ':' || l.port as url
from
  aws_ec2_application_load_balancer as lb,
  aws_ec2_load_balancer_listener as l
where
  lb.scheme LIKE 'internet-facing'
  and lb.state_code LIKE 'active'
  and l.load_balancer_arn = lb.arn;