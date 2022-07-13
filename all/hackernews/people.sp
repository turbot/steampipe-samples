dashboard "People" {

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
People
🞄
[Posts](http://localhost:9194/hackernews.dashboard.Posts)
🞄
[Search](http://localhost:9194/hackernews.dashboard.Search)
🞄
[Sources](http://localhost:9194/hackernews.dashboard.Sources)
🞄
[Submissions](http://localhost:9194/hackernews.dashboard.Submissions)
      EOT
    }

  }

  table {
    title = "hacker news people with scores > 500"
    query = query.people
    column "by" {
    href = "http://localhost:9194/hackernews.dashboard.Submissions?input.hn_user={{.'by'}}"
    }
    column "twitter" {
    href = "https://twitter.com/{{.'twitter'}}"
    }
    column "github" {
    href = "https://github.com/{{.'github'}}"
    }
  }

}