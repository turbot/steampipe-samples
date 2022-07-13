dashboard "Urls" {

  title = "Steampipe + Hacker News"

  tags = {
    service = "Hacker News"
  }

  container {
    
    text {
      width = 4
      value = <<EOT
[Home](http://localhost:9194/hackernews.dashboard.Home)
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
.
Urls
      EOT
    }

  }

  container {

    table  {
      width = 6
      query = query.urls
      column "url" {
          wrap = "all"
      }
    }

    container {
      width = 6

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
            url != '<null>'
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
            url != '<null>'
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