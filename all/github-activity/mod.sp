mod "github" {
  title = "github"
}

locals {
  default_org = {
    name = "turbot"
  }
  default_user = {
    name = "judell"
  }
}

dashboard "github_activity" {

  input "username" {
    title = "username"
    width = 2
    query = query.usernames
  }

  input "repo_pattern" {
    title = "repo pattern"
    width = 2
    option "turbot" {}
    option "steampipe-mod" {}
    option "steampipe-plugin" {}
  }

  input "issue_or_pull" {
    title = "issue/pull"
    width = 2
    option "issue" {}
    option "pull" {}
    option "both" {}
  }

  input "open_or_closed" {
    title = "open/closed"
    width = 2
    option "open" {}
    option "closed" {}
    option "both" {}
  }

  container {

    table {
      title = "my team's github activity"
      width = 12
      args = {
        "username"       = self.input.username.value
        "repo_pattern"   = self.input.repo_pattern.value
        "issue_or_pull"  = self.input.issue_or_pull.value
        "open_or_closed" = self.input.open_or_closed.value
      }
      sql = <<EOT
        select
            html_url,
            title,
            to_char(updated_at, 'YYYY-MM-DD') as updated_at,
            to_char(created_at, 'YYYY-MM-DD') as created_at,
            to_char(closed_at, 'YYYY-MM-DD') as closed_at
        from
            github_activity(
              $1,
              $2, 
              ''
            )
        where
            html_url ~ 
              case 
                when $3 = 'issue' then 'issue'
                when $3 = 'pull' then 'pull'
                else 'issue|pull'
              end 
            and case 
              when $4 = 'open' then closed_at is null
              when $4 = 'closed' then closed_at is not null
              else closed_at is null or closed_at is not null
            end
      EOT
      param "username" {}
      param "repo_pattern" {}
      param "issue_or_pull" {}
      param "open_or_closed" {}
      column "url"{
        wrap = "all"
      }
      column "title" {
        wrap = "all"
      }
    }

  }

}

query "usernames" {
  sql   = <<EOT
    with user_info as (
      select 
        jsonb_array_elements_text(member_logins) as member_login
      from
        github_organization
      where 
        login = '${local.default_org.name}'
    )
    select
      '${local.default_user.name}' as label,
      '${local.default_user.name}' as value
    union all
    select
      member_login as label, 
      member_login as value
    from 
      user_info
  EOT  
}