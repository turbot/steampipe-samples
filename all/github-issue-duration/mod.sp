mod "github_issue_duration" {
}

locals {
  repo_pattern = "turbot/steampipe-(plugin|mod)"
}

dashboard "GitHub_issue_duration" {

  input "repo" {
    width = 4
    sql = <<EOQ
      select
        full_name as label,
        full_name as value
      from
        github_my_repository
      where
        full_name ~ '${local.repo_pattern}'
      order by
        full_name
    EOQ
  }

  container {

    card {
      width = 2
      args = [ self.input.repo ]
      sql = <<EOQ
        select count(*) as "all issues" from github_issue where repository_full_name = $1
      EOQ
    }

    card {
      width = 2
      args = [ self.input.repo ]
      sql = <<EOQ
        select count(*) as "open" from github_issue where repository_full_name = $1 and closed_at is null
      EOQ
    }

    card {
      width = 2
      args = [ self.input.repo ]
      sql = <<EOQ
        select count(*) as "closed" from github_issue where repository_full_name = $1 and closed_at is not null
      EOQ
    }

    card {
      width = 3
      args = [ self.input.repo ]
      sql = <<EOQ
        select to_char(min(created_at),'YYYY-MM-DD') as "oldest" from github_issue where repository_full_name = $1 and closed_at is not null
      EOQ
    }

    card {
      width = 3
      args = [ self.input.repo ]
      sql = <<EOQ
        select to_char(max(created_at),'YYYY-MM-DD') as "newest" from github_issue where repository_full_name = $1 and closed_at is not null
      EOQ
    }

  }

  table {
    width = 6
    args = [ self.input.repo ]
    sql = <<EOQ
      with data as (
        select * from pct_issues_open_for_repo_by_interval($1, interval '1 day')
        union
        select * from pct_issues_open_for_repo_by_interval($1, interval '2 day')
        union
        select * from pct_issues_open_for_repo_by_interval($1, interval '3 day')
        union
        select * from pct_issues_open_for_repo_by_interval($1, interval '5 day')
        union
        select * from pct_issues_open_for_repo_by_interval($1, interval '7 day')
        union
        select * from pct_issues_open_for_repo_by_interval($1, interval '1 month')
        union
        select * from pct_issues_open_for_repo_by_interval($1, interval '2 month')
        union
        select * from pct_issues_open_for_repo_by_interval($1, interval '3 month')
        union
        select * from pct_issues_open_for_repo_by_interval($1, interval '6 month')
      )
      select 
        _interval as "interval",
        case 
          when lag(closed_in_interval) over () = closed_in_interval then ''
          when closed_in_interval = 0 then ''
          else closed_in_interval::text
        end as "issues closed",
        case 
          when lag(pct_closed_in_interval) over () = pct_closed_in_interval then ''
          when pct_closed_in_interval = 0 then ''
          else pct_closed_in_interval::text
        end as "percent closed"
      from 
        data

    EOQ
  }

  card {
    width = 3
    args = [ self.input.repo ]
    sql = <<EOQ
      select pct_closed_in_interval as "pct closed in a week" from pct_issues_open_for_repo_by_interval($1, interval '7 day')
    EOQ
  }

  card {
    width = 3
    args = [ self.input.repo ]
    sql = <<EOQ
      select pct_closed_in_interval as "pct closed in a month" from pct_issues_open_for_repo_by_interval($1, interval '1 month')
    EOQ
  }

  table {
    sql = <<EOQ
      with repos as (
        select
          full_name
        from
        github_my_repository
      where
        full_name ~ '${local.repo_pattern}'
      order by
        full_name
      ),
      data as (
        select
          full_name,
          ( select pct_closed_in_interval as "pct closed in a week" from pct_issues_open_for_repo_by_interval(full_name, interval '7 day') ),
          ( select pct_closed_in_interval as "pct closed in a month" from pct_issues_open_for_repo_by_interval(full_name, interval '1 month') ),
          ( select pct_closed_in_interval as "pct closed in 6 months" from pct_issues_open_for_repo_by_interval(full_name, interval '6 month') )
        from
          repos
      ) 
      select 
        *
      from 
        data
      where
        "pct closed in 6 months" != '0'
    EOQ
  }


}


/*

create or replace function pct_issues_open_for_repo_by_interval(_repo text, _interval interval) 
  returns table(
    _interval interval,
    closed_in_interval numeric, 
    pct_closed_in_interval numeric
  ) as $$
    with closed_issues as (
      select 
        created_at,
        closed_at
      from
        github_issue
      where
        repository_full_name = _repo
        and closed_at is not null
    ),
    in_interval as (
      select 
        count(*) as count_in_interval
      from 
        closed_issues 
      where 
        closed_at - created_at <= _interval
    )
    select
      _interval,
      count_in_interval,
      case 
        when (select count(*) from closed_issues) = 0 then 0
        else round ( count_in_interval::numeric / (select count(*) from closed_issues) * 100 , 0)
      end
    from
      in_interval;
 $$ language sql;

*/