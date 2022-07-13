dashboard "People" {

  tags = {
    service = "Hackernews"
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
    sql = <<EOQ
    with data as (
      select distinct
        h.by,
        ( select count(*) from hn_items_all where by = h.by ) as stories,
        ( select sum(descendants::int) from hn_items_all where descendants != '<null>' and by = h.by group by h.by ) as comments,
        replace(g.html_url, 'https://github.com/', '') as github,
        case 
          when g.name is null then ''
          else g.name
        end as gh_name,
        followers::int as gh_followers,
        case 
          when g.twitter_username is null then ''
          else g.twitter_username
        end as twitter
      from
        hn_items_all h
      join
        github_user g
      on 
      h.by = g.login
        where
      h.score::int > 500
    ),
    expanded as (
      select
        u.karma,
        d.*,
        ( select (public_metrics->>'followers_count')::int as tw_followers from twitter_user where d.twitter != '' and username = d.twitter )
      from 
        data d
      join
        hackernews_user u 
      on 
        u.id = d.by
    )
    select
      by,
      karma,
      stories,
      comments,
      github,
      gh_name,
      gh_followers,
      twitter,
      tw_followers
    from
      expanded
    order by
        karma desc
    EOQ
    column "by" {
    wrap = "all"
    href = "http://localhost:9194/hackernews.dashboard.Submissions?input.hn_user={{.'by'}}"
    }
    column "twitter" {
    wrap = "all"
    href = "https://twitter.com/{{.'twitter'}}"
    }
    column "github" {
    wrap = "all"
    href = "https://github.com/{{.'github'}}"
    }
    column "gh_name" {
    wrap = "all"
    }
  }

}