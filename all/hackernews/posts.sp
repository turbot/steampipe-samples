dashboard "Posts" {

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
Posts
🞄
[Search](http://localhost:9194/hackernews.dashboard.Search)
🞄
[Sources](http://localhost:9194/hackernews.dashboard.Sources)
🞄
Submissions
🞄
[Urls](http://localhost:9194/hackernews.dashboard.Urls)

      EOT
    }

  }

  container {

    table {
      title = "top-rated posts"
      sql = <<EOQ
        select 
          id as link,
          to_char(time::timestamptz, 'MM-DD hHH24') as time,
          title,
          by,
          score::int,
          descendants::int as comments,
          url,
          substring(url from 'http[s]*://([^/$]+)') as domain
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
        href = "http://localhost:9194/hackernews.dashboard.Submissions?input.hn_user={{.'by'}}"
      }
      column "url" {
        wrap = "all"
      }
      column "domain" {
        href = "http://localhost:9194/hackernews.dashboard.Search?input.search_term={{.'domain'}}"
      }

    }

  }

}
