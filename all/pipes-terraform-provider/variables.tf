# Variables
variable "slack_webhook" {
  type = string
  # default     = "https://hooks.slack.com/services/AB2CD4EFG/H04IJKLMNO4/PqRstUvwXyzA7bCDeFGHijKL"  # Update this
  description = "The Slack Webhook to send notifications"
}

variable "aws_connections" {
  type        = map(any)
  description = "Map of the list of AWS connections. Update in terraform.tfvars"
  default = {
    "aws_aaa" = {
      regions     = ["us-east-1", "us-east-2"]
      role_arn    = "arn:aws:iam::012345678901:role/turbot_pipes",
      # The format of external id is ^(u|o)_[a-z0-9_]{20}:[a-z0-9]{8}$`
      external_id = "o_cjbl573762fpr8u545g0:94g9mipd"
    },
    "aws_aab" = {
      regions     = ["us-east-1", "us-east-2"]
      role_arn    = "arn:aws:iam::123456789012:role/turbot_pipes",
      external_id = "o_cjbl573762fpr8u545g0:42f5nvk3"
    },
    # Add more here...
  }
}

