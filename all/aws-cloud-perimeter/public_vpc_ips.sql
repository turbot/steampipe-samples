select
	eni.association_public_ip AS public_ip
from
	aws_ec2_network_interface AS eni
where
	eni.association_public_ip is not Null;
