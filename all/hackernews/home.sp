dashboard "Home" {

  title = "Steampipe + Hacker News"

  tags = {
    service = "Hacker News"
  }

  container {

    text {
      width = 4
      value = <<EOT

Home
🞄
[People](http://localhost:9194/hackernews.dashboard.People)
🞄
[Posts](http://localhost:9194/hackernews.dashboard.Posts)
🞄
[Search](http://localhost:9194/hackernews.dashboard.Search)
🞄
[Sources](http://localhost:9194/hackernews.dashboard.Sources)
🞄
[Submissions](http://localhost:9194/hackernews.dashboard.Submissions)
🞄
[Urls](http://localhost:9194/hackernews.dashboard.Urls)
      EOT
    }

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
      title = "users with > 50 posts"
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
          posts > 50
        limit
          25
      EOQ
    }

    chart {
      title = "users with scores > 50"
      width = 6
      sql = <<EOQ
        select
          by,
          max(score::int) as max_score
        from
          hn_items_all
        where
          score::int > 50
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
      title = "company mentions: last 4 hours"
      query = query.mentions
      args = [ local.companies, 240, 0 ]
    }

    chart {
      base = chart.companies_base
      width = 4
      type = "donut"
      title = "company mentions: last 24 hours"
      query = query.mentions
      args = [ local.companies, 1440, 0 ]
    }

    chart {
      base = chart.companies_base
      width = 4
      type = "donut"
      title = "company mentions: last 14 days"
      query = query.mentions
      args = [ local.companies, 20160, 0 ] 
    }

  }

  container {

    chart {
      base = chart.languages_base
      width = 4
      type = "donut"
      title = "language mentions: last 4 hours"
      query = query.mentions
      args = [ local.languages, 240, 0 ]
    }

    chart {
      base = chart.languages_base
      width = 4
      type = "donut"
      title = "language mentions: last 24 hours"
      query = query.mentions
      args = [ local.languages, 1440, 0 ]
    }

    chart {
      base = chart.languages_base
      width = 4
      type = "donut"
      title = "language mentions: last 14 days"
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
      title = "cloud mentions: last 4 hours"
      query = query.mentions
      args = [ local.clouds, 240, 0 ]
    }

    chart {
      base = chart.cloud_base
      width = 4
      type = "donut"
      title = "cloud mentions: last 24 hours"
      query = query.mentions
      args = [ local.clouds, 1440, 0 ]
    }

    chart {
      base = chart.cloud_base
      width = 4
      type = "donut"
      title = "cloud mentions: last 14 days"
      query = query.mentions
      args = [ local.clouds, 20160, 0 ] 
    }

  }

  container {

    chart {
      base = chart.db_base
      width = 4
      type = "donut"
      title = "db mentions: last 4 hours"
      query = query.mentions
      args = [ local.dbs, 240, 0 ]
    }

    chart {
      base = chart.db_base
      width = 4
      type = "donut"
      title = "db mentions: last 24 hours"
      query = query.mentions
      args = [ local.dbs, 1440, 0 ]
    }

    chart {
      base = chart.db_base
      width = 4
      type = "donut"
      title = "db mentions: last 14 days"
      query = query.mentions
      args = [ local.dbs, 20160, 0 ] 
    }

  }

  card "cache_warmer_people" {
    value = "caching..."
    width = 2
    query = query.people
  }    


}

