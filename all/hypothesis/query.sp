query "recently_annotated_urls" {
  sql = <<EOQ
    with thread_data as (
      select
        uri,
        title,
        count(*),
        min(created) as first,
        max(created) as last,
        sum(jsonb_array_length(refs)) as refs,
        array_agg(distinct username) as thread_participants
      from 
        hypothesis_search
      where
        query = 'group=' || $1 || '&limit=' || $2 || '&wildcard_uri=https://' || $3 || '/*'
      group
        by uri, title
      order 
        by max(created) desc
    )
    select
      uri as value,
      title as label,
      json_build_object(
        'annos,replies', '(' || count || ' notes, ' || refs || ' replies)',
        'most_recent', substring(last from 1 for 10)
      ) as tags,
      count,
      refs
    from 
      thread_data
    where
      date(last) - date(first) > 0
      and refs is not null
  EOQ
  param "group" {}
  param "search_limit" {}
  param "media_source" {}
}

query "threads" {
  sql = <<EOQ
    with refs as (
        select
        refs ->> 0 as top_level_id,
        refs,
        jsonb_array_length(refs) as refcount
        from
        hypothesis_search
        where 
        query = 'uri=' || $1 || '&group=' || $2
        and refs is not null
    ),
    ids_to_names as (
        select
        id,
        username
        from
        hypothesis_search
        where 
        query = 'uri=' || $1 || '&group=' || $2
    ),
    ordered_threads as (
        select 
        *
        from
        refs
        order by
        top_level_id, refcount desc
    ),
    distinct_threads as (
        select distinct on (top_level_id)
        *
        from
        ordered_threads
    ),
    unnested as (
        select 
        top_level_id,
        refcount,
        jsonb_array_elements_text(refs) as ref
        from
        distinct_threads d
        order by
        refcount desc
    ),
    name_joined as (
        select
        *
        from
        unnested u 
        join
        ids_to_names i 
        on
        u.ref = i.id
    )
    select
        top_level_id,
        refcount as thread_length,
        array_to_string(array_agg(username), ' → ') as user_path
    from
        name_joined
    group by
        top_level_id, refcount
    order by 
        refcount desc
  EOQ
  param "annotated_url" {}
  param "group" {}
}

query "top_annotators" {
  sql = <<EOT
    select 
      username, 
      count(*) as annotations
    from 
      hypothesis_search
    where query = 'limit=' || $1
      || '&group=' || $2
      || case when $3 = 'all' then '' else '&uri=' || $3 end
    group by 
      username 
    order by 
      annotations desc
    limit 10
  EOT 
  param "search_limit" {}
  param "groups" {}
  param "annotated_uris" {}
}

query "top_domains" {
  sql   = <<EOT
    with domains as (
      select 
        (regexp_matches(uri, '.*://([^/]*)'))[1] as domain
      from 
        hypothesis_search
    where query = 'limit=' || $1
      || '&group=' || $2
      || case when $3 = 'all' then '' else '&uri=' || $3 end
    )
    select 
      domain, 
      count(*) as annotations
    from 
      domains
    group by 
      domain
    order by 
      annotations desc
    limit 10
  EOT
  param "search_limit" {}
  param "groups" {}
  param "annotated_uris" {}
}

query "top_tags" {
  sql   = <<EOT
    with tags as (
      select 
        jsonb_array_elements_text(tags) as tag
      from 
        hypothesis_search
      where query = 'limit=' || $1
        || '&group=' || $2
        || case when $3 = 'all' then '' else '&uri=' || $3 end
    )
    select 
      tag,
      count(*) as tags
    from tags
    group by tag
    order by tags desc
    limit 10  
  EOT
  param "search_limit" {}
  param "groups" {}
  param "annotated_uris" {}
}

query "conversational_data" {
   sql = <<EOQ
    with data as (
      select
        username,
        id,
        case 
          when refs is null then array['']
          else ( select array_agg(ref) from jsonb_array_elements_text(refs) as ref )
        end as refs
      from 
        hypothesis_search
      where
        query = 'group=' || $1 || '&limit=' || $2 || '&uri=' || $3 
    ),
    unnested as (
      select
        *,
        unnest(refs) as ref
      from 
        data
      group by
        id, refs, username
    ),
    prepared as (
      select
        case 
          when ref = '' then 'root'
          else ref
        end as from_id,
        id,
        (select username from data d where d.id = u.id ) as title,
        $1 as category,
        array_length(refs,1) as length
      from 
        unnested u
      where 
        ref = ''
        or ref = refs[array_length(refs,1)]
    )
    select 
      * 
    from 
      prepared
    union 
    select 
      null as from_id,
      'root' as id,
      'root' as title,
      'root' as category,
      1 as length
    from 
      prepared
  EOQ
  param "group" {}
  param "limit" {}
  param "annotated_url" {}
}
