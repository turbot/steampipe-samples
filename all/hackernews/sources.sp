dashboard "Sources" {

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
Sources
🞄
[Submissions](http://localhost:9194/hackernews.dashboard.Submissions)
🞄
[Urls](http://localhost:9194/hackernews.dashboard.Urls)
      EOT
    }

  }


  table {
    width = 6
    query = query.domains
    column "domain" {
      href = "http://localhost:9194/hackernews.dashboard.Sources?input.domain={{.'domain'}}"
    }    
  }

  container {
    width = 6

    container  {

      input "domain" {
        width = 6
        placeholder = "search or choose domain"
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
        args = [ self.input.domain  ]
        query = query.source_detail
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