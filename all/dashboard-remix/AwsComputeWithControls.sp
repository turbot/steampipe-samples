locals {
  project_tag_values = ["Boston", "Cairo", "Kolkata"]
}

dashboard "AwsComputeWithControls" {

	title = "AWS compute with controls"

	tags = {
		service = "AAA"
	}

  container {
    title = "aws ec2_instances"
    width = 6

    input "instance_input" {
      query = aws_insights.query.ec2_instance_input
    }

    card "ec2_instance_status" {
      width = 2
      base = card.ec2_instance_status
    }
     
    table {
      type = "line"
      args = [ self.input.instance_input.value ]
      base = table.ec2_instance_overview
    }

    table {
      type = "line"
      base = table.ec2_public_ips
    }

    table {
      type = "line"
      args = [ self.input.instance_input.value ]
      base = table.ec2_security_groups
    }

  }    

  container {
    width = 6

    benchmark "aws_ec2_controls" {
      title         = "AWS EC2 controls"
      children = [
        aws_compliance.control.ec2_instance_in_vpc,
        aws_compliance.control.ec2_instance_not_publicly_accessible,
        aws_compliance.control.ec2_instance_user_data_no_secrets,
        control.ec2_instance_project_tag
      ]
    }
    
  }

}

control "ec2_instance_project_tag" {
  args = [ local.project_tag_values ]
  title       = "The EC2 Instance project tag has an allowed value"
  description = "Check if the EC2 Instance project tag has an allowed value."
  sql  = <<EOQ
    with data as (
      select 
        arn,
        tags,
        jsonb_object_keys(tags) as tag_name
      from
        aws_ec2_instance
    ),
    project_tags as (
      select
        arn,
        tags,
        $1::jsonb as project_tag_values,
        tags ->> 'Project' as project_tag_value
      from
        data 
      where
        tag_name = 'Project'
    )
    select
      arn as resource,
      case 
        when project_tag_values ? project_tag_value then 'ok' 
        else 'alarm'
      end as status,
      case 
        when project_tag_values ? project_tag_value then 'Project tag has allowed value'
        else 'Project tag has wrong value' 
      end as reason,
      project_tag_value
    from
      project_tags
  EOQ
  
}