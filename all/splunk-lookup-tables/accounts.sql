select
  id, name, status,
  tags ->> 'ExecutiveOwner' as Executive_Owner,
  tags ->> 'TechnicalContact' as Technical_Contact,
  tags ->> 'DataClassification' as Data_Classification
  tags ->> 'environment' as Environment,
from 
  aws_payer.aws_organizations_account;
