dashboard "Links" {

  tags = {
    service = "Link Checker"
  }

  container {

    input "scheme" {
      title = "scheme"
      type = "combo"
      width = 2
      option "https://" {}
      option "http://" {}
    }

    input "target_url" {
      title = "target url"
      type = "combo"
      width = 4
      option "steampipe.io" {}
    }

    table "links" {
      args = [ 
        self.input.scheme.value,
        self.input.target_url.value 
      ]
      query = query.links
      column "link" {
        href = "${local.host}/steampipe_stats.dashboard.Links?input.scheme={{.'scheme'}}&input.target_url={{.'link'}}"
        wrap = "all"
      }
      column "context" {
        wrap = "all"
      }
      column "response_error" {
        wrap = "all"
      }

    }

  }

}


