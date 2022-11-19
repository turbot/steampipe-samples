dashboard "acme" {

  tags = {
      service = "Acme"
    }

  container {

    width = 6

    benchmark "aws_tags" {
      title         = "Benchmark: No prohibited AWS tags"
      children = [
        aws_tags.control.cloudtrail_trail_prohibited,
        aws_tags.control.cloudwatch_log_group_prohibited,
      ]
    }

    chart "aws_regions" {
      type = "donut"
      title = "Regions for Cloudwatch log groups and CloudTrail trails"
      sql = <<EOQ
        with cloudwatch_log_group_regions as (
          select 
            region,
            count(*)
          from
            aws_cloudwatch_log_group
          group by 
            region
        ),
        cloudtrail_trail_regions as (
          select
            region,
            count(*)
          from
            aws_cloudtrail_trail
          group by
            region
        )
        select * from  cloudwatch_log_group_regions
        union 
        select * from  cloudtrail_trail_regions
        order by count desc, region
      EOQ
    }

  }

  container {

    width = 6

    benchmark {
      base = benchmark.repo_semver
    }

    table {
      title = "Plugins and mods updated recently"
      sql = <<EOQ

        select
          html_url as Repo,
          stargazers_count as Stars,
          to_char(pushed_at, 'YYYY-MM-DD') as pushed_at
        from
          github_search_repository
        where
          query = 'steampipe-plugin in:name org:turbot'

        union 

        select
          html_url as Repo,
          stargazers_count as Stars,
          to_char(pushed_at, 'YYYY-MM-DD') as pushed_at
        from
          github_search_repository
        where
          query = 'steampipe-mod in:name org:turbot'

        order by
          pushed_at desc
        limit 10
      EOQ
      column "Repo" {
        wrap = "all"
      }

    }  

  }
 
}



