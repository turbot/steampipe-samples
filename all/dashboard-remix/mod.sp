mod "local" {
  title = "mymod"
  require {
    mod "github.com/turbot/steampipe-mod-aws-compliance" {
      version = "latest"
    }
    mod "github.com/turbot/steampipe-mod-aws-insights" {
      version = "latest"
    }
    mod "github.com/turbot/steampipe-mod-aws-tags" {
      version = "latest"
    }
    mod "github.com/turbot/steampipe-mod-azure-insights" {
      version = "latest"
    }
  }
}
