-- https://rwvrandomhg.execute-api.us-east-1.amazonaws.com/dev_system

select 'https://' || api_id || '.execute-api.' || region || '.amazonaws.com/' || stage_name as url
from aws_api_gatewayv2_stage;