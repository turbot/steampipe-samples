mod "local" {
  title = "AWS Top 10"

  require {
    mod "github.com/turbot/steampipe-mod-aws-compliance" {
      version = "*"
    }
    mod "github.com/turbot/steampipe-mod-aws-perimeter" {
      version = "*"
    }
  }

}
