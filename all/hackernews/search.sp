dashboard "Search" {

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
Search 
🞄
[Sources](http://localhost:9194/hackernews.dashboard.Sources)
🞄
[Submissions](http://localhost:9194/hackernews.dashboard.Submissions)
🞄
[Urls](http://localhost:9194/hackernews.dashboard.Urls)
      EOT
    } 
  } 

  container  {

    input "search_term" {
      width = 4
      placeholder = "search_term (matches in urls or titles, can be regex)"
      type = "text"
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
      column "title" {
        wrap = "all"
      }
      column "url" {
        wrap = "all"
      }
      column "id" {
        href = "https://news.ycombinator.com/item?id={{.'id'}}"
      }
      column "by" {
        href = "http://localhost:9194/hackernews.dashboard.Submissions?input.hn_user={{.'by'}}"
      }

  }

}