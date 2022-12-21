select url_config ->> 'FunctionUrl' as url
from aws_lambda_function
where url_config is not Null;