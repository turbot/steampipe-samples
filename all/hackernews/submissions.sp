dashboard "Submissions" {

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
Submissions
🞄
[Urls](http://localhost:9194/hackernews.dashboard.Urls)
      EOT
    }

  }


  container {
    width = 6

    input "hn_user" {
      width = 4
      placeholder = "search or choose user"
      title = "hn user"
      type = "select"
      sql = <<EOQ
        select distinct
          h.by as label,
          h.by as value
        from
          hn_items_all h
        order by
          by
      EOQ    
    }

    table  {
      args = [
        self.input.hn_user.value
      ]
      query = query.submission_times
      column "id" {
        href = "https://news.ycombinator.com/item?id={{.'id'}}"
      }
      column "title" {
        wrap = "all"
      }
      column "url" {
        wrap = "all"
      }
    }

  }

  container {
    width = 6

    input "since_days_ago" {
      width = 4
      title = "since days ago"
      option "30" {}
      option "14" {}
      option "7" {}
    }


    chart  {
      args = [
        self.input.hn_user.value,
        self.input.since_days_ago
      ]
      axes {
        x {
          title {
            value = "days"
          }
        }
        y {
          title {
            value = "submissions"
          }
        }
      }
      query = query.submission_days
    }

  }

}