query "links" {
  sql = <<EOQ
    with html as (
      select 
        response_body
      from
        net_http_request
      where
        url = $1 || $2
    ),
    link_contexts as (
      select
        (regexp_matches(response_body, '.{40,40} href="[^"]+".{40,40}', 'g'))[1] as context
      from
        html
    ),
    raw_links as (
      select
        context,
        (regexp_match(context, ' href="([^"]+)"'))[1] as link
      from
        link_contexts
    ),
    normalized_links as (
      select
        case 
          when left(link, 1) = '/' then $1 || (regexp_match($2, '[^/]+'))[1] || link
          else link
        end as link,
        context
      from
        raw_links
    ),
    http_links as (
      select
        *
      from 
        normalized_links
      where
        left(link, 4) = 'http'
      order by 
        link
    )
    select
      $2 as target,
      regexp_replace(h.link, 'http[s]*://', '') as link,
      regexp_match(h.link, 'http[s]*://') as scheme,
      n.response_status_code,
      n.response_error,
      h.context
    from 
      http_links h
    join 
      net_http_request n 
    on 
      h.link = n.url
    order by
      n.response_status_code desc
  EOQ
  param "scheme" {}
  param "target_url" {}
}

