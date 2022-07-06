dashboard "Sources" {

  tags = {
    service = "Hackernews"
  }

  table {
    width = 6
    query = query.domains
    column "domain" {
      wrap = "all"
      href = "http://localhost:9194/hackernews.dashboard.Sources?input.domain={{.'domain'}}"
    }    
  }

  container {
    width = 6

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
            h.id as link,
            to_char(h.time::timestamptz, 'MM-DD hHH24') as time,
            h.score,
            h.url,
            ( select count(*) from hn_items_all where url = h.url ) as occurrences,
            h.title
          from
            hn_items_all h
          where 
            h.url ~ $1
          order by
            h.score::int desc
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