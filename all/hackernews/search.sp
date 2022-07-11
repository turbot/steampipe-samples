dashboard "Search" {

  tags = {
    service = "Hackernews"
  }

  container  {


    input "search_term" {
      width = 2
      placeholder = "search_term (found in urls or titles, can be regex)"
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
          url,
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