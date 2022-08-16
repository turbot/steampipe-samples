dashboard "Repos" {

  tags = {
    service = "Hacker News"
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