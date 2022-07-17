dashboard "People" {

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
🞄
[Urls](http://localhost:9194/hackernews.dashboard.Urls)
      EOT
    }

  }

  table {
    title = "hacker news people with max score > 300"
    sql = "select * from hn_people"
    column "by" {
    href = "http://localhost:9194/hackernews.dashboard.Submissions?input.hn_user={{.'by'}}"
    }
    column "twitter_user" {
    href = "https://twitter.com/{{.'twitter'}}"
    }
    column "github_user" {
    href = "https://github.com/{{.'github'}}"
    }
  }

}