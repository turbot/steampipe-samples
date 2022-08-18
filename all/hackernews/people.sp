dashboard "People" {

  tags = {
    service = "Hacker News"
  }

  container {
    
    text {
      width = 6
      value = <<EOT
[Home](http://${local.host}:9194/hackernews.dashboard.Home)
🞄
People
🞄
[Posts](http://${local.host}:9194/hackernews.dashboard.Posts)
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

  table {
    title = "hacker news people with max score > 200"
    sql = "select * from hn_people order by karma::int desc"
    column "by" {
    href = "http://${local.host}:9194/hackernews.dashboard.Submissions?input.hn_user={{.'by'}}"
    }
    column "twitter_user" {
    href = "https://twitter.com/{{.'twitter'}}"
    }
    column "github_user" {
    href = "https://github.com/{{.'github'}}"
    }
  }

}