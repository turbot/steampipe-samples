mod "hackernews" {
  title = "hackernews"
}

chart "companies_base" {
  series "company_mentions" {
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
  series "language_mentions" {
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
  series "os_mentions" {
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
  series "cloud_mentions" {
    point "AWS" {
      color = "brown"
    }
    point "Azure" {
      color = "green"
    }
    point "Google Cloud" {
      color = "red"
    }
  }
}

chart "db_base" {
  series "db_mentions" {
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
      title = "companies mentioned: 24 to 12 hours ago" // companies
      query = query.hn_companies_mentioned
      args = [ 1440, 720 ] // companies
    }

    text {
      width = 8
      value = "run *python animate.py* to start the animation"
    }
  }

}

dashboard "submissions" {

  tags = {
    service = "Hackernews"
  }

  input "hn_user" {
    width = 4
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

  container {

    table  {
      args = [
        self.input.hn_user.value
      ]
      sql = <<EOQ
        select
          id as link,
          title,
          url,
          time,
          descendants as comments
        from 
          hn_items_all
        where
          by = $1
        order by
          time desc
      EOQ
      column "link" {
        href = "https://news.ycombinator.com/item?id={{.'link'}}"
      }
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
      query = query.hn_companies_mentioned
      args = [ 240, 0 ]
    }

    chart {
      base = chart.companies_base
      width = 4
      type = "donut"
      title = "companies mentioned: last 24 hours"
      query = query.hn_companies_mentioned
      args = [ 1440, 0 ]
    }

    chart {
      base = chart.companies_base
      width = 4
      type = "donut"
      title = "companies mentioned: last 7 days"
      query = query.hn_companies_mentioned
      args = [ 10080, 0 ] 
    }

  }

  container {

    chart {
      base = chart.languages_base
      width = 4
      type = "donut"
      title = "languages mentioned: last 4 hours"
      query = query.hn_languages_mentioned
      args = [ 240, 0 ]
    }

    chart {
      base = chart.languages_base
      width = 4
      type = "donut"
      title = "languages mentioned: last 24 hours"
      query = query.hn_languages_mentioned
      args = [ 1440, 0 ]
    }

    chart {
      base = chart.languages_base
      width = 4
      type = "donut"
      title = "languages mentioned: last 7 days"
      query = query.hn_languages_mentioned
      args = [ 10080, 0 ]
    }

  }

  container {

    chart {
      base = chart.os_base
      width = 4
      type = "donut"
      title = "os mentions: last 4 hours"
      query = query.os_mentions
      args = [ 240, 0 ]
    }

    chart {
      base = chart.os_base
      width = 4
      type = "donut"
      title = "os mentions: last 24 hours"
      query = query.os_mentions
      args = [ 1440, 0 ]
    }

    chart {
      base = chart.os_base
      width = 4
      type = "donut"
      title = "os mentions: last 7 days"
      query = query.os_mentions
      args = [ 10080, 0 ]
    }

  }

  container {

    chart {
      base = chart.cloud_base
      width = 4
      type = "donut"
      title = "clouds mentioned: last 4 hours"
      query = query.cloud_mentions
      args = [ 240, 0 ]
    }

    chart {
      base = chart.cloud_base
      width = 4
      type = "donut"
      title = "clouds mentioned: last 24 hours"
      query = query.cloud_mentions
      args = [ 1440, 0 ]
    }

    chart {
      base = chart.cloud_base
      width = 4
      type = "donut"
      title = "clouds mentioned: last 7 days"
      query = query.cloud_mentions
      args = [ 10080, 0 ] 
    }

  }

  container {

    chart {
      base = chart.db_base
      width = 4
      type = "donut"
      title = "dbss mentioned: last 4 hours"
      query = query.db_mentions
      args = [ 240, 0 ]
    }

    chart {
      base = chart.db_base
      width = 4
      type = "donut"
      title = "dbs mentioned: last 24 hours"
      query = query.db_mentions
      args = [ 1440, 0 ]
    }

    chart {
      base = chart.db_base
      width = 4
      type = "donut"
      title = "dbs mentioned: last 7 days"
      query = query.db_mentions
      args = [ 10080, 0 ] 
    }

  }




  container {

    table {
      width = 4
      title = "top-rated stories"
      sql = <<EOQ
        select 
          id as link,
          to_char(time::timestamptz, 'MM-DD hHH24') as time,
          title || ' (' || by || ')' as title_author,
          score::int,
          descendants::int as comments
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
      column "title_author" {
        wrap = "all"
      }
    }

    table {
      width = 8
      title = "github and twitter info for hn users with scores > 20"
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
            end as github_name,
            followers::int as gh_followers,
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
            h.score::int > 20
        ),
        expanded as (
          select
            u.karma,
            d.*,
            ( select (public_metrics->>'followers_count')::int as tw_followers from twitter_user where d.twitter != '' and username = d.twitter )
          from 
            data d
          join
            hackernews_user u 
          on 
            u.id = d.by
        )
        select
          by as all_hn_stories,
          karma,
          stories,
          comments,
          github,
          github_name,
          gh_followers,
          twitter,
          tw_followers
        from
          expanded
      EOQ
      column "all_hn_stories" {
        href = "http://localhost:9194/hackernews.dashboard.submissions?input.hn_user={{.'all_hn_stories'}}"
      }
      column "twitter" {
        href = "https://twitter.com/{{.'twitter'}}"
      }
      column "github" {
        href = "https://github.com/{{.'github'}}"
      }
    }
  }

}

query "hn_companies_mentioned" {
  sql = <<EOQ
    with names as (
      select
        unnest( array[
          'Amazon',
          'AMD',
          'Apple',
          'CloudFlare',
          'Facebook',
          'Google',
          'Intel',
          'Microsoft',
          'Netflix',
          'Tesla',
          'Toshiba',
          'Twitter',
          'SpaceX',
          'Sony',
          'Stripe'
        ] ) as name
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
            and (extract(epoch from now() - time::timestamptz) / 60)::int between symmetric $1 and $2
        ) as company_mentions
        from
          names
    )
    select
      *
    from
      counts
    where
      company_mentions > 0
    order by 
      lower(name)
  EOQ
  param "min_minutes_ago" {}
  param "max_minutes_ago" {}
}

query "hn_languages_mentioned" {
  sql = <<EOQ
    with names as (
      select
        unnest( array [
          'C#',
          'C\+\+',
          'CSS',
          'Erlang',
          'golang',
          'Haskell',
          'HTML',
          'Java ',
          'JavaScript',
          'JSON',
          'PHP',
          'Python',
          'Rust',
          'SQL',
          'Swift',
          'TypeScript',
          'WebAssembly|WASM',
          'XML'
          ] ) as name
        ),
        counts as (
          select
            replace(name,'\','') as name,
            (
              select
                count(*)
              from
                hn_items_all
              where
                title ~* name
                and (extract(epoch from now() - time::timestamptz) / 60)::int between symmetric $1 and $2
            ) as language_mentions
            from
              names
        )
        select
          *
        from
          counts
        where
          language_mentions > 0
        order by 
          lower(name)
  EOQ
  param "min_minutes_ago" {}
  param "max_minutes_ago" {}
}

query "os_mentions" {
  sql = <<EOQ
    with names as (
      select
        unnest( array [
          'Android',
          'iOS',
          'Linux',
          'macOS',
          'Windows'
          ] ) as name
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
                and (extract(epoch from now() - time::timestamptz) / 60)::int between symmetric $1 and $2
            ) as os_mentions
            from
              names
        )
        select
          *
        from
          counts
        where
          os_mentions > 0
        order by 
          lower(name)
  EOQ
  param "min_minutes_ago" {}
  param "max_minutes_ago" {}
}

query "cloud_mentions" {
  sql = <<EOQ
    with names as (
      select
        unnest( array [
          'AWS',
          'Azure',
          'Google Cloud|GCP'
          ] ) as name
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
                and (extract(epoch from now() - time::timestamptz) / 60)::int between symmetric $1 and $2
            ) as cloud_mentions
            from
              names
        )
        select
          *
        from
          counts
        where
          cloud_mentions > 0
        order by 
          lower(name)
  EOQ
  param "min_minutes_ago" {}
  param "max_minutes_ago" {}
}

query "db_mentions" {
  sql = <<EOQ
    with names as (
      select
        unnest( array [
          'DB2',
          'Citus',
          'CouchDB',
          'MongoDB',
          'MySQL|MariaDB',
          'Oracle',
          'Postgres',
          'Redis',
          'SQL Server',
          'Timescale',
          'SQLite',
          'Yugabyte'
          ] ) as name
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
                and (extract(epoch from now() - time::timestamptz) / 60)::int between symmetric $1 and $2
            ) as db_mentions
            from
              names
        )
        select
          *
        from
          counts
        where
          db_mentions > 0
        order by 
          lower(name)
  EOQ
  param "min_minutes_ago" {}
  param "max_minutes_ago" {}
}

