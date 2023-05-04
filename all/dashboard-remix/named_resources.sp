card "ec2_instance_status" {
  type  = "info"
  width = 4
  args = [ self.input.instance_input.value ]
  query = aws_insights.query.ec2_instance_status
}

table "ec2_instance_overview" {
  query = aws_insights.query.ec2_instance_overview 
}

table "ec2_public_ips" {
  title = "public ips"
  type = "line"
  sql = <<EOQ
    select
      instance_id,
      public_ip_address
    from
      aws_ec2_instance
    where
      public_ip_address is not null
    EOQ
}

table "ec2_security_groups" {
  title = "security groups"
  query = aws_insights.query.ec2_instance_security_groups
  column "Group ID" {
    href = "/aws_insights.dashboard.vpc_security_group_detail?input.security_group_id={{.'Group ID' | @uri}}"
  }
}
