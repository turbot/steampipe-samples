dashboard "search_subreddits" {
  
  tags = {
    service = "reddit"
  }

  title = "Search subreddits"

  container {
    
    input "subreddit_name_match" {
      width = 4
      title = "match subreddit name"
      type = "text"
    }

    input "subreddit_title_match" {
      width = 2
      title = "match title too?"
      type = "select"
      option "no" {}
      option "yes" {}
    }

  }

  container {
    
    chart {
      width = 6
      type = "donut"
      args = [
        self.input.subreddit_name_match,
        self.input.subreddit_title_match
      ]
      sql = <<EOQ
        select
          subscribers,
          display_name || ' (rank=' || rank || ')' as subreddit
        from
          reddit_subreddit_search
        where
          query = $1 
          and display_name ~ $1
          and 
            case 
              when $2 = 'yes' then title ~ $1
              else true
            end
        order by
          subscribers desc
      EOQ
    }

    table {
      width = 6
      args = [
        self.input.subreddit_name_match,
        self.input.subreddit_title_match
      ]
      sql = <<EOQ
        select
          rank,
          subscribers as subs,
          'https://reddit.com/r/' || display_name as subreddit,
          title
        from
          reddit_subreddit_search
        where
          query = $1 
          and display_name ~ $1
          and 
            case 
              when $2 = 'yes' then title ~ $1
              else true
            end
        order by
          rank
      EOQ
      column "title" {
        wrap = "all"
      }
    }

  }

}
