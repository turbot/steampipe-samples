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
      query = query.posts
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
