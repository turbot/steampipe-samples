dashboard "Posts" {

  tags = {
    service = "Hacker News"
  }

  container {
    
    text {
      width = 4
      value = <<EOT
[Home](http://${local.host}:9194/hackernews.dashboard.Home)
🞄
[People](http://${local.host}:9194/hackernews.dashboard.People)
🞄
Posts
🞄
[Repos](http://${local.host}:9194/hackernews.dashboard.Repos)
🞄
[Search](http://${local.host}:9194/hackernews.dashboard.Search)
🞄
[Sources](http://${local.host}:9194/hackernews.dashboard.Sources)
🞄
[Submissions](http://${local.host}:9194/hackernews.dashboard.Submissions?input.hn_user=none)
🞄
[Urls](http://${local.host}:9194/hackernews.dashboard.Urls)

      EOT
    }

  }

  container {

    table {
      title = "top-rated posts"
      query = query.posts
      column "link" {
        href = "https://news.ycombinator.com/item?id={{.'link'}}"
      }
      column "title" {
        wrap = "all"
      }
      column "by" {
        href = "http://${local.host}:9194/hackernews.dashboard.Submissions?input.hn_user={{.'by'}}"
      }
      column "url" {
        wrap = "all"
      }
      column "domain" {
        href = "http://${local.host}:9194/hackernews.dashboard.Search?input.search_term={{.'domain'}}"
      }

    }

  }

}
