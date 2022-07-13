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
      lower(name)
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
      time desc
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
      and time::timestamptz > now() - ($2 || ' day')::interval
    group by 
      day
    order by
      day
  EOQ
  param "hn_user" {}
  param "since_days_ago" {}
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
      c.count desc
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