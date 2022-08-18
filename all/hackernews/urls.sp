dashboard "Urls" {

  tags = {
    service = "Hacker News"
  }

  container {
    
    text {
      width = 6
      value = <<EOT
[Home](http://${local.host}:9194/hackernews.dashboard.Home)
🞄
[People](http://${local.host}:9194/hackernews.dashboard.People)
🞄
[Posts](http://${local.host}:9194/hackernews.dashboard.Posts)
🞄
[Repos](http://${local.host}:9194/hackernews.dashboard.Repos)
🞄
[Search](http://${local.host}:9194/hackernews.dashboard.Search)
🞄
[Sources](http://${local.host}:9194/hackernews.dashboard.Sources)
🞄
[Submissions](http://${local.host}:9194/hackernews.dashboard.Submissions?input.hn_user=none)
🞄
Urls
      EOT
    }

  }

  container {

    table  {
      width = 7
      query = query.urls
      column "url" {
        wrap = "all"
      }
    }

    container {
      width = 5

      chart  {
        title = "domains by count"    
        type = "donut"
        sql = <<EOQ
          select 
            substring(url from 'http[s]*://([^/$]+)') as domain,
            count(*)
          from
            hn_items_all
          where
            url != ''
          group by
            domain
          order by 
            count desc
          limit
            15
        EOQ
      }

      chart  {
        title = "domains by max score"    
        type = "donut"
        sql = <<EOQ
          select 
            substring(url from 'http[s]*://([^/$]+)') as domain,
            max(score::int) as "max score"
          from
            hn_items_all
          where
            url != ''
          group by
            domain
          order by 
            "max score" desc
          limit
            15
        EOQ
      }


    }

  }

}