dashboard "Submissions" {

  tags = {
    service = "Hackernews"
  }

  container {
    width = 6

    input "hn_user" {
      width = 4
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
      option "7" {}
      option "14" {}
      option "30" {}
      option "60" {}
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