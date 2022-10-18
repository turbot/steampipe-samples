select
	eni.network_interface_id,
	eni.private_ip,
	eni.vpc_id as vpc_id,
	eni.region,
	eni.status,
	eni.interface_type,
	eni.association_public_ip as public_ip,
	case
		when eni.attached_instance_id is not null 
			then eni.attached_instance_id
		else eni.description
	end as attached_resource,
	vpc.tags ->> 'name' as vpc_name,
	org.name as account_name
from
	aws_ec2_network_interface as eni,
	aws_vpc as vpc,
	aws_payer.aws_organizations_account as org
where vpc.vpc_id = eni.vpc_id
	and org.id = eni.account_id;
