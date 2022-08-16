dashboard "Repos" {

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
[Posts](http://${local.host}:9194/hackernews.dashboard.Posts)
🞄
Repos
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


  container  {

    table {
      title = "company repos: last 30 days"
      query = query.repos_by_company
      args = [ local.companies ]
      column "by" {
        href = "http://${local.host}:9194/hackernews.dashboard.Submissions?input.hn_user={{.'by'}}"
      }
    }

  }

}