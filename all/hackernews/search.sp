dashboard "Search" {

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
Search 
🞄
[Sources](http://${local.host}:9194/hackernews.dashboard.Sources)
🞄
[Submissions](http://${local.host}:9194/hackernews.dashboard.Submissions?input.hn_user=none)
🞄
[Urls](http://${local.host}:9194/hackernews.dashboard.Urls)
      EOT
    } 
  } 

  container  {

    input "search_term" {
      width = 4
      placeholder = "search_term (matches in urls or titles, can be regex)"
      type = "text"
    }

    text "search_examples" {
      width = 8
      value = <<EOT
Examples: 
[gpt](http://${local.host}:9194/hackernews.dashboard.Search?input.search_term=gpt),
[go.+generic](http://${local.host}:9194/hackernews.dashboard.Search?input.search_term=%20go.%2bgeneric),
[simonwillison](http://${local.host}:9194/hackernews.dashboard.Search?input.search_term=simonwillison)
[github.com/microsoft](http://${local.host}:9194/hackernews.dashboard.Search?input.search_term=github.com%2Fmicrosoft), 
[github.com.+sqlite](http://${local.host}:9194/hackernews.dashboard.Search?input.search_term=github.com.%2bsqlite),
[nytimes.+/technology](http://${local.host}:9194/hackernews.dashboard.Search?input.search_term=nytimes.%2b/technology)
      EOT
    }

  }


    table {
      args = [
        self.input.search_term
      ]
      sql = <<EOQ
        select
          id,
          by,
          title,
          to_char(time::timestamptz, 'MM-DD hHH24') as time,
          case 
            when url = '<null>' then ''
            else url
          end as url,
          score,
          descendants as comments
        from 
          hn_items_all
        where
           title ~* $1 or url ~* $1
        order by
          score::int desc
      EOQ
      column "url" {
        wrap = "all"
      }
      column "id" {
        href = "https://news.ycombinator.com/item?id={{.'id'}}"
      }
      column "by" {
        href = "http://${local.host}:9194/hackernews.dashboard.Submissions?input.hn_user={{.'by'}}"
      }

  }

}