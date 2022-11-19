mod "local" {
  title = "mod_acme"
  require {
    mod "github.com/turbot/steampipe-mod-aws-tags" {
      version = "latest"
    }
  }
}
