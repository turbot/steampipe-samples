dashboard "AwsAndAzureCompute" {

	title = "AWS + Azure Compute"

	tags = {
		service = "AAA"
	}

  container {
	  width = 6

    title = "aws ec2 instances"

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

    title = "azure compute vms"

    input "vm_input" {
      query = azure_insights.query.compute_virtual_machine_input
    }

    card {
      width = 5
      type = "info"
      query = azure_insights.query.compute_virtual_machine_status
      args  = [self.input.vm_input.value]
    }

  	table {
			type = "line"
			args = [ self.input.vm_input.value ]
      query = azure_insights.query.compute_virtual_machine_overview
  	}

    table {
			title = "public ips"
			type = "line"
      sql = <<EOQ
			  select
				  name,
					public_ips
				from
				  azure_compute_virtual_machine
				where 
				  public_ips is not null
			EOQ
  	}

    table {
      title = "Security Groups"
      query = azure_insights.query.compute_virtual_machine_security_groups
      args  = [self.input.vm_input.value]

      column "Name" {
        href = "/azure_insights.dashboard.network_security_group_detail?input.nsg_id={{ .'Security Group ID' | @uri }}"
      }
    }
	
	}


}