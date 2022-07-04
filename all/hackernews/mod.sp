mod "hackernews" {
  title = "hackernews"
}

locals {
  companies = [ 
    "Amazon",
    "AMD",
    "Apple",
    "CloudFlare",
    "Facebook",
    "Google",
    "Intel",
    "Microsoft",
    "Netflix",
    "Tesla",
    "Toshiba",
    "Twitter",
    "SpaceX",
    "Sony",
    "Stripe"  
  ]
  languages = [
      "C#",
      "C\\+\\+",
      "CSS",
      "Erlang",
      "golang",
      "Haskell",
      "HTML",
      "Java ",
      "JavaScript",
      "JSON",
      "PHP",
      "Python",
      "Rust",
      "SQL",
      "Swift",
      "TypeScript",
      "WebAssembly|WASM",
      "XML"
  ]
  operating_systems = [
    "Android",
    "iOS",
    "Linux",
    "macOS",
    "Windows"
  ]
  clouds = [
    "AWS",
    "Azure",
    "Google Cloud|GCP"  
  ]
  dbs = [
    "DB2",
    "Citus",
    "CouchDB",
    "MongoDB",
    "MySQL|MariaDB",
    "Oracle",
    "Postgres",
    "Redis",
    "SQL Server",
    "Timescale",
    "SQLite",
    "Steampipe",
    "Supabase",
    "Yugabyte"
  ]
}

chart "companies_base" {
  series "mentions" {
    point "Amazon" {
      color = "Purple"
    }
    point "AMD" {
      color = "SandyBrown"
    }
    point "Apple" {
      color = "Crimson"
    }
    point "CloudFlare" {
      color = "Brown"
    }
    point "Facebook" {
      color = "RoyalBlue"
    }
    point "Google" {
      color = "SeaGreen"
    }
    point "Intel" {
      color = "Wheat"
    }
    point "Microsoft" {
      color = "Blue"
    }
    point "Netflix" {
      color = "DarkRed"
    }
    point "Tesla" {
      color = "Gray"
    }
    point "Toshiba" {
      color = "Goldenrod"
    }
    point "Twitter" {
      color = "PaleTurquoise"
    }
    point "Sony" {
      color = "Gold"
    }
    point "SpaceX" {
      color = "Black"
    }
    point "Stripe" {
      color = "SaddleBrown"
    }
  }  
}

chart "languages_base" {
  series "mentions" {
    point "C#" {
      color = "#823085"
    }
    point "C++" {
      color = "orange"
    }
    point "CSS" {
      color = "pink"
    }
    point "Erlang" {
      color = "DarkSalmon"
    }
    point "golang" {
      color = "#4B8BBE"
    }
    point "Haskell" {
      color = "rgb(94,80,134)"
    }
    point "HTML" {
      color = "GoldenRod"
    }
    point "Java " {
      color = "#f89820"
    }
    point "JavaScript" {
      color = "#F0DB4F"
    }
    point "JSON" {
      color = "DarkSalmon"
    }
    point "PHP" {
      color = "beige"
    }
    point "Python" {
      color = "#4B8BBE"
    }
    point "Rust" {
      color = "black"
    }
    point "SQL" {
      color = "ForestGreen"
    }
    point "Swift" {
      color = "#F05138"
    }
    point "TypeScript" {
      color = "purple"
    }
    point "WebAssembly|WASM" {
      color = "#6856E7"
    }
    point "XML" {
      color = "DarkSeaGreen"
    }
  }
}

chart "os_base" {
  series "mentions" {
    point "Android" {
      color = "green"
    }
    point "iOS" {
      color = "crimson"
    }
    point "macOS" {
      color = "red"
    }
    point "Windows" {
      color = "blue"
    }
    point "Linux" {
      color = "gray"
    }
  }
}

chart "cloud_base" {
  series "mentions" {
    point "AWS" {
      color = "brown"
    }
    point "Azure" {
      color = "blue"
    }
    point "Google Cloud|GCP" {
      color = "#F4B400"
    }
  }
}

chart "db_base" {
  series "mentions" {
    point "DB2" {
      color = "brown"
    }
    point "Citus" {
      color = "green"
    }
    point "MongoDB" {
      color = "gray"
    }
    point "MySQL|MariaDB" {
      color = "orange"
    }
    point "Oracle" {
      color = "red"
    }
    point "Postgres" {
      color = "lightblue"
    }
    point "Steampipe" {
      color = "black"
    }
    point "Supabase" {
      color = "yellow"
    }
    point "Timescale" {
      color = "purple"
    }
    point "SQLite" {
      color = "blue"
    }
    point "Yugabyte" {
      color = "lightgreen"
    }

  }
}

dashboard "animated_company_mentions" {

  tags = {
    service = "Hackernews"
  }

  container {

    chart {
      base = chart.companies_base
      width = 8
      type = "donut"
      title = "companies mentioned: 72 to 60 hours ago" // companies
      query = query.mentions
      args = [ local.companies, 4320, 3600 ] // companies
    }

    text {
      width = 8
      value = "run *python animate.py* to start the animation"
    }
  }

}

dashboard "sources" {

  tags = {
    service = "Hackernews"
  }

  table {
    width = 4
    query = query.domains
    column "domain" {
      wrap = "all"
      href = "http://localhost:9194/hackernews.dashboard.sources?input.domain={{.'domain'}}"
    }    
  }

  container {
    width = 8

    container  {

      input "domain" {
        width = 3
        sql = <<EOQ
          with domains as (
            select distinct
              substring(url from 'http[s]*://([^/$]+)') as domain
            from
              hn_items_all
          )
          select
            domain as label,
            domain as value
          from
            domains
          order by
            domain
        EOQ    
      }

      chart {
        args = [
          self.input.domain
        ]
        query = query.domain_detail
      }

      table {
        args = [
          self.input.domain
        ]
        sql = <<EOQ
          select
            id as link,
            score,
            url,
            title
          from
            hn_items_all 
          where 
            url ~ $1
          order by
            score::int desc
          limit 40
        EOQ
        column "link" {
          href = "https://news.ycombinator.com/item?id={{.'link'}}"
        }
        column "url" {
          wrap = "all"
        } 
        column "title" {
          wrap = "all"
        } 
      }

    }

  }


}

dashboard "submissions" {

  tags = {
    service = "Hackernews"
  }

  container {
    width = 6

    input "hn_user" {
      width = 4
      title = "hn user"
      type = "select"
      sql = <<EOQ
        select distinct
          h.by as label,
          h.by as value
        from
          hn_items_all h
        order by
          by
      EOQ    
    }

    table  {
      args = [
        self.input.hn_user.value
      ]
      query = query.submission_times
      column "id" {
        href = "https://news.ycombinator.com/item?id={{.'id'}}"
      }
      column "title" {
        wrap = "all"
      }
      column "url" {
        wrap = "all"
      }
    }

  }

  container {
    width = 6

    input "since_days_ago" {
      width = 4
      title = "since days ago"
      option "7" {}
      option "14" {}
      option "30" {}
      option "60" {}
    }


    chart  {
      args = [
        self.input.hn_user.value,
        self.input.since_days_ago
      ]
      axes {
        x {
          title {
            value = "days"
          }
        }
        y {
          title {
            value = "submissions"
          }
        }
      }
      query = query.submission_days
    }

  }

}

dashboard "all_hackernews_stats" {

  tags = {
    service = "Hackernews"
  }

  container {

    card {
      width = 2
      sql = <<EOQ
        select count(*) as stories from hn_items_all
      EOQ
    }

    card {
      width = 2
      sql = <<EOQ
        select count(*) as "ask hn" from hn_items_all where title ~ '^Ask HN'
      EOQ
    }

    card {
      width = 2
      sql = <<EOQ
        select count(*) as "show hn" from hn_items_all where title ~ '^Show HN'
      EOQ
    }

    card {
      width = 2
      sql = <<EOQ
        select
          count( distinct( to_char( time::timestamptz, 'MM-DD' ) ) ) as days
        from
          hn_items_all
      EOQ
    }

    card {
      width = 2
      sql = <<EOQ
        select to_char(min(time::timestamptz), 'MM-DD hHH24') as "oldest" from hn_items_all
      EOQ
    }

    card {
      width = 2
      sql = <<EOQ
        select to_char(max(time::timestamptz), 'MM-DD hHH24') as "newest" from hn_items_all
      EOQ
    }
  }

  container {

    card {
      width = 3
      sql = <<EOQ
        select max(score::int) as "max score" from hn_items_all
      EOQ
    }
    
    card {
      width = 3
      sql = <<EOQ
        select round(avg(score::int), 1) as "avg score" from hn_items_all

      EOQ
    }

    card {
      width = 3
      sql = <<EOQ
        select round(avg(score::int), 1) as "avg ask score" from hn_items_all where title ~ '^Ask HN'
      EOQ
    }

    card {
      width = 3
      sql = <<EOQ
        select round(avg(score::int), 1) as "avg show score" from hn_items_all where title ~ '^Show HN'
      EOQ
    }

  }

  container {
    width = 12
    
    chart {
      title = "users with > 5 posts"
      width = 6
      sql = <<EOQ
        with data as (
          select
            by,
            count(*) as posts
          from
            hn_items_all
          group by
            by
          order by
            posts desc
        )
        select 
          * 
        from
          data
        where
          posts > 5
        limit
          25
      EOQ
    }

    chart {
      title = "users with max scores > 3"
      width = 6
      sql = <<EOQ
        select
          by,
          max(score::int) as max_score
        from
          hn_items_all
        where
          score::int > 3
        group by 
          by
        order by
          max_score desc
        limit 
          25
      EOQ
    }
    
  }

  container {

    chart {
      width = 6
      title = "stories by hour"
      sql = <<EOQ
        with data as (
          select
            time::timestamptz
          from
            hn_items_all
        )
        select
          to_char(time,'MM:DD HH24') as hour,
          count(*)
        from 
          data
        group by
          hour
        order by
          hour
      EOQ
    }

    chart {
      width = 6
      title = "ask and show by hour"
      sql = <<EOQ
        with ask_hn as (
          select
            to_char(time::timestamptz,'MM:DD HH24') as hour
          from
            hn_items_all
          where
            title ~ '^Ask HN:'
        ),
        show_hn as (
          select
            to_char(time::timestamptz,'MM:DD HH24') as hour
          from
            hn_items_all
          where
            title ~ '^Show HN:'
        )
        select
          hour,
          count(a.*) as "Ask HN",
          count(s.*) as "Show HN"
        from 
          ask_hn a
        left join 
          show_hn s 
        using 
          (hour)
        group by
          hour
        order by
          hour
      EOQ
    }

  }

  container {

    chart {
      base = chart.companies_base
      width = 4
      type = "donut"
      title = "companies mentioned: last 4 hours"
      query = query.mentions
      args = [ local.companies, 240, 0 ]
    }

    chart {
      base = chart.companies_base
      width = 4
      type = "donut"
      title = "companies mentioned: last 24 hours"
      query = query.mentions
      args = [ local.companies, 1440, 0 ]
    }

    chart {
      base = chart.companies_base
      width = 4
      type = "donut"
      title = "companies mentioned: last 14 days"
      query = query.mentions
      args = [ local.companies, 20160, 0 ] 
    }

  }

  container {

    chart {
      base = chart.languages_base
      width = 4
      type = "donut"
      title = "languages mentioned: last 4 hours"
      query = query.mentions
      args = [ local.languages, 240, 0 ]
    }

    chart {
      base = chart.languages_base
      width = 4
      type = "donut"
      title = "languages mentioned: last 24 hours"
      query = query.mentions
      args = [ local.languages, 1440, 0 ]
    }

    chart {
      base = chart.languages_base
      width = 4
      type = "donut"
      title = "languages mentioned: last 14 days"
      query = query.mentions
      args = [ local.languages, 20160, 0 ]
    }

  }

  container {

    chart {
      base = chart.os_base
      width = 4
      type = "donut"
      title = "os mentions: last 4 hours"
      query = query.mentions
      args = [ local.operating_systems, 240, 0 ]
    }

    chart {
      base = chart.os_base
      width = 4
      type = "donut"
      title = "os mentions: last 24 hours"
      query = query.mentions
      args = [ local.operating_systems, 1440, 0 ]
    }

    chart {
      base = chart.os_base
      width = 4
      type = "donut"
      title = "os mentions: last 14 days"
      query = query.mentions
      args = [ local.operating_systems, 20160, 0 ]
    }

  }

  container {

    chart {
      base = chart.cloud_base
      width = 4
      type = "donut"
      title = "clouds mentioned: last 4 hours"
      query = query.mentions
      args = [ local.clouds, 240, 0 ]
    }

    chart {
      base = chart.cloud_base
      width = 4
      type = "donut"
      title = "clouds mentioned: last 24 hours"
      query = query.mentions
      args = [ local.clouds, 1440, 0 ]
    }

    chart {
      base = chart.cloud_base
      width = 4
      type = "donut"
      title = "clouds mentioned: last 14 days"
      query = query.mentions
      args = [ local.clouds, 20160, 0 ] 
    }

  }

  container {

    chart {
      base = chart.db_base
      width = 4
      type = "donut"
      title = "dbs mentioned: last 4 hours"
      query = query.mentions
      args = [ local.dbs, 240, 0 ]
    }

    chart {
      base = chart.db_base
      width = 4
      type = "donut"
      title = "dbs mentioned: last 24 hours"
      query = query.mentions
      args = [ local.dbs, 1440, 0 ]
    }

    chart {
      base = chart.db_base
      width = 4
      type = "donut"
      title = "dbs mentioned: last 14 days"
      query = query.mentions
      args = [ local.dbs, 20160, 0 ] 
    }

  }

  container {

    table {
      width = 6
      title = "top-rated stories"
      sql = <<EOQ
        select 
          id as link,
          to_char(time::timestamptz, 'MM-DD hHH24') as time,
          title,
          by,
          score::int,
          descendants::int as cmnts,
          url
        from
          hn_items_all
        where 
          score != '<null>'
          and descendants != '<null>'
        order by 
          score desc
        limit 100
      EOQ
      column "link" {
        href = "https://news.ycombinator.com/item?id={{.'link'}}"
      }
      column "title" {
        wrap = "all"
      }
      column "by" {
        href = "http://localhost:9194/hackernews.dashboard.submissions?input.hn_user={{.'by'}}"
        wrap = "all"
      }
      column "url" {
        wrap = "all"
      }

    }

    table {
      width = 6
      title = "github and twitter info for hn users with scores > 25"
      sql = <<EOQ
        with data as (
          select distinct
            h.by,
            ( select count(*) from hn_items_all where by = h.by ) as stories,
            ( select sum(descendants::int) from hn_items_all where descendants != '<null>' and by = h.by group by h.by ) as comments,
            replace(g.html_url, 'https://github.com/', '') as github,
            case 
              when g.name is null then ''
              else g.name
            end as gh_name,
            followers::int as gh_follwrs,
            case 
              when g.twitter_username is null then ''
              else g.twitter_username
            end as twitter
          from
            hn_items_all h
          join
            github_user g
          on 
            h.by = g.login
          where
            h.score::int > 25
        ),
        expanded as (
          select
            u.karma,
            d.*,
            ( select (public_metrics->>'followers_count')::int as tw_follwrs from twitter_user where d.twitter != '' and username = d.twitter )
          from 
            data d
          join
            hackernews_user u 
          on 
            u.id = d.by
        )
        select
          by,
          karma,
          stories,
          comments as cmnts,
          github,
          gh_name,
          gh_follwrs,
          twitter,
          tw_follwrs
        from
          expanded
      EOQ
      column "by" {
        wrap = "all"
        href = "http://localhost:9194/hackernews.dashboard.submissions?input.hn_user={{.'by'}}"
      }
      column "twitter" {
        wrap = "all"
        href = "https://twitter.com/{{.'twitter'}}"
      }
      column "github" {
        wrap = "all"
        href = "https://github.com/{{.'github'}}"
      }
      column "gh_name" {
        wrap = "all"
      }
    }
  }

}

query "mentions" {
  sql = <<EOQ
    with names as (
      select
        unnest( $1::text[] ) as name
    ),
    counts as (
      select
        name,
        (
          select
            count(*)
          from
            hn_items_all
          where
            title ~* name
            and (extract(epoch from now() - time::timestamptz) / 60)::int between symmetric $2 and $3
        ) as mentions
        from
          names
    )
    select
      replace(name, '\', '') as name,
      mentions
    from
      counts
    where
      mentions > 0
    order by 
      lower(name)
  EOQ
  param "names" {}
  param "min_minutes_ago" {}
  param "max_minutes_ago" {}
}

query "submission_times" {
  sql = <<EOQ
    select
      id,
      to_char(time::timestamptz, 'MM-DD hHH24') as time,
      title,
      url,
      case
        when descendants = '<null>' then ''
        else descendants
      end as cmts
    from 
      hn_items_all
    where
      by = $1
    order by
      time desc
  EOQ
  param "hn_user" {}

}

query "submission_days" {
  sql = <<EOQ
    select
      to_char(time::timestamptz, 'MM-DD') as day,
      count(to_char(time::timestamptz, 'MM-DD'))
    from 
      hn_items_all
    where
      by = $1
      and time::timestamptz > now() - ($2 || ' day')::interval
    group by 
      day
    order by
      day
  EOQ
  param "hn_user" {}
  param "since_days_ago" {}
}

query "domains" {
  sql = <<EOQ
    with domains as (
      select
        url,
        substring(url from 'http[s]*://([^/$]+)') as domain
    from 
      hn_items_all
    where
      url != '<null>'
    ),
    counted as (
      select 
        domain,
        count(*)
      from 
        domains
      group by
        domain
      order by
        count desc
    )
    select
      *
    from
      counted
    where
      count > 5
  EOQ
}

query "domain_detail" {
  sql = <<EOQ
    with items_by_day as (
      select
        to_char(time::timestamptz, 'MM-DD') as day,
        substring(url from 'http[s]*://([^/$]+)') as domain
    from 
      hn_items_all
    where
      substring(url from 'http[s]*://([^/$]+)') = $1
    )
    select 
      day,
      count(*)
    from 
      items_by_day
    group by
      day
    order by
      day
  EOQ
  param "domain" {}
}


