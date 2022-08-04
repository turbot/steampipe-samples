query "mentions" {
  sql = <<EOQ
    with names as (
      select
        unnest( $1::text[] ) as name
    ),
    counts as (
      select
        name,
        (
          select
            count(*)
          from
            hn_items_all
          where
            title ~* name
            and (extract(epoch from now() - time::timestamptz) / 60)::int between symmetric $2 and $3
        ) as mentions
        from
          names
    )
    select
      replace(name, '\', '') as name,
      mentions
    from
      counts
    where
      mentions > 0
    order by 
      mentions desc
  EOQ
  param "names" {}
  param "min_minutes_ago" {}
  param "max_minutes_ago" {}
}

query "submission_times" {
  sql = <<EOQ
    select
      id,
      to_char(time::timestamptz, 'MM-DD hHH24') as time,
      title,
      url,
      score,
      case
        when descendants = '<null>' then ''
        else descendants
      end as comments
    from 
      hn_items_all
    where
      by = $1
    order by
      score::int desc
  EOQ
  param "hn_user" {}

}

query "submission_days" {
  sql = <<EOQ
    select
      to_char(time::timestamptz, 'MM-DD') as day,
      count(to_char(time::timestamptz, 'MM-DD'))
    from 
      hn_items_all
    where
      by = $1
    group by 
      day
    order by
      day desc
  EOQ
  param "hn_user" {}
}

query "domains" {
  sql = <<EOQ
    with domains as (
      select
        url,
        substring(url from 'http[s]*://([^/$]+)') as domain
    from 
      hn_items_all
    where
      url != '<null>'
    ),
    avg_and_max as (
      select
        substring(url from 'http[s]*://([^/$]+)') as domain,
        avg(score::int) as avg_score,
        max(score::int) as max_score,
        avg(descendants::int) as avg_comments,
        max(descendants::int) as max_comments
      from
        hn_items_all
      group by
        substring(url from 'http[s]*://([^/$]+)')
    ),
    counted as (
      select 
        domain,
        count(*)
      from 
        domains
      group by
        domain
      order by
        count desc
    )
    select
      a.domain,
      c.count,
      a.max_score,
      round(a.avg_score, 1) as avg_score,
      a.max_comments,
      round(a.avg_comments, 1) as avg_comments
    from
      avg_and_max a
    join
      counted c 
    using 
      (domain)
    where
      c.count > 5
    order by
      max_score desc
  EOQ
}

query "domain_detail" {
  sql = <<EOQ
    with items_by_day as (
      select
        to_char(time::timestamptz, 'MM-DD') as day,
        substring(url from 'http[s]*://([^/$]+)') as domain
    from 
      hn_items_all
    where
      substring(url from 'http[s]*://([^/$]+)') = $1
    )
    select 
      day,
      count(*)
    from 
      items_by_day
    group by
      day
    order by
      day
  EOQ
  param "domain" {}
}

query "source_detail" {
  sql = <<EOQ
    select
      h.id as link,
      to_char(h.time::timestamptz, 'MM-DD hHH24') as time,
      h.score,
      h.url,
      ( select count(*) from hn_items_all where url = h.url ) as occurrences,
      h.title
    from
      hn_items_all h
    where 
      h.url ~ $1
    order by
      h.score::int desc
  EOQ
  param "source_domain" {}
}

query "people" {
  sql = <<EOQ
    with hn_users_and_max_scores as (
      select 
        by,
        max(score::int) as max_score
      from
        hn_items_all
      group by
        by
      having
        max(score::int) > 200
    ),
    hn_info as (
      select 
        h.by,
        h.max_score,
        ( select count(*) from hn_items_all where by = h.by ) as stories,
        ( select sum(descendants::int) from hn_items_all where descendants != '<null>' and by = h.by group by h.by ) as comments
      from 
        hn_users_and_max_scores h
      where
        h.by != 'aiobe' -- causes "resource not accessible by integration" in gh actions, no idea why
    ),
    plus_gh_info as (
      select
        h.*,
        g.html_url as github_url,
        case 
          when g.name is null then ''
          else g.name
        end as gh_name,
        g.followers::int as gh_followers,
        g.twitter_username,
        g.public_repos
      from
        hn_info h
      left join
        github_user g
      on 
        h.by = g.login
      order by
        h.by
    ) 
    select
      p.by,
      u.karma,
      p.max_score,
      p.stories,
      p.comments,
      p.github_url,
      p.gh_name,
      p.public_repos,
      p.gh_followers,
      case 
        when p.twitter_username is null then ''
        else 'https://twitter.com/' || p.twitter_username
      end as twitter_url
    from
      plus_gh_info p 
    join
      hackernews_user u 
    on 
      p.by = u.id
    order by
      karma desc
   EOQ
}

query "posts" {
  sql = <<EOQ
    select 
      id as link,
      to_char(time::timestamptz, 'MM-DD hHH24') as time,
      title,
      by,
      score::int,
      descendants::int as comments,
      url,
      case
        when url = '' then ''
        else substring(url from 'http[s]*://([^/$]+)')
      end as domain
    from
      hn_items_all
    where 
      score != '<null>'
      and descendants != '<null>'
    order by 
      score desc
    limit 100
  EOQ
}

query "urls" {
  sql = <<EOQ
    select
      url,
      to_char(time::timestamptz, 'MM-DD hHH24') as time,
      sum(score::int) as score,
      sum(descendants::int) as comments
    from
      hn_items_all
    where
      url != ''
    group by
      url,
      time,
      score
    order by
      score desc
    limit 
      500
  EOQ
}

query "stories_by_hour" {
  sql = <<EOQ
    with data as (
      select
        time::timestamptz
      from
        hn_items_all
      where
        time::timestamptz > now() - interval '10 day'
    ),
    by_hour as (
      select
         regexp_replace(to_char(time, 'Dy DD HH24'), '(\w)(\w{2,2})(.+)', '\1\3') as day_hour,
        to_char(time,'MM-DD hHH24') as hour,
        count(*)
      from 
        data
      group by
        day_hour, hour
    )
    select
      day_hour,
      count
    from
      by_hour
    order by
      hour
  EOQ
}

query "ask_and_show_by_hour" {
  sql = <<EOQ
    with ask_hn_data as (
      select
        time::timestamptz
      from
        hn_items_all
      where
        time::timestamptz > now() - interval '10 day'
        and title ~ '^Ask HN'
    ),
    ask_hn_by_hour as (
      select
        regexp_replace(to_char(time, 'Dy DD HH24'), '(\w)(\w{2,2})(.+)', '\1\3') as day_hour,
        to_char(time,'MM-DD hHH24') as hour,
        count(*)
      from 
        ask_hn_data
      group by
        day_hour, hour
      order by
        hour
    ),
    ask_hn as (
      select
        day_hour,
        count as ask_count
      from
        ask_hn_by_hour
    ),
    show_hn_data as (
      select
        time::timestamptz
      from
        hn_items_all
      where
        time::timestamptz > now() - interval '7 day'
        and title ~ '^Show HN'
    ),
    show_hn_by_hour as (
      select
        regexp_replace(to_char(time, 'Dy DD HH24'), '(\w)(\w{2,2})(.+)', '\1\3') as day_hour,
        to_char(time,'MM-DD hHH24') as hour,
        count(*)
      from 
        show_hn_data
      group by
        day_hour, hour
      order by
        hour
    ),
    show_hn as (
      select
        day_hour,
        count as show_count
      from
        show_hn_by_hour
    )
    select
      day_hour,
      ask_count as "Ask HN",
      show_count as "Show HN"
    from 
      ask_hn a
    left join 
      show_hn s 
    using 
      (day_hour)
  EOQ
}

query "create_scores_and_comments" {
  sql = <<EOQ
    create table hn_scores_and_comments as ( 
      select 
        id, 
        score, 
        descendants 
      from 
        hn_items_all 
      where 
        score::int > 5 
      order by
        time desc 
    )
  EOQ
}

query "new_scores_and_comments" {
  sql = <<EOQ
    create table new_sc as ( 
      with urls as ( 
        select 'https://hacker-news.firebaseio.com/v0/item/' || sc.id || '.json' as url
      from 
        hn_scores_and_comments sc 
      order by 
        url
      ), 
      new_sc as ( 
        select  
          response_body::jsonb->>'id' as id, 
          response_body::jsonb->>'score' as new_score, 
          response_body::jsonb->>'descendants' as new_descendants 
      from 
        net_http_request n 
      join 
        urls u 
      on 
        u.url = n.url
      )
      select 
        sc.id, 
        sc.score, 
        sc.descendants, 
        n.new_score, 
        n.new_descendants 
      from 
        new_sc n 
      join 
        hn_scores_and_comments sc 
      on
        n.id = sc.id
    )          
  EOQ
}

query "update_scores_and_comments" {
  sql = <<EOQ
    update 
      hn_items_all a 
    set 
      score = new_sc.new_score, 
      descendants = new_sc.new_descendants 
    from 
      csv.new_sc 
    where new_sc.id = a.id
  EOQ
}
