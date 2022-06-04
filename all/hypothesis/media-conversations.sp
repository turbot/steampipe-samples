dashboard "media_conversations" {

  tags = {
    service  = "Hypothesis"
    type     = "Conversations"
  }

  title = "Media Conversations"

  input "groups" {
      title = "Hypothesis group"
      width = 3
      sql = <<EOQ
        with groups as (
          select 
            jsonb_array_elements(groups) as group_info
          from 
            hypothesis_profile
        )
        select
          group_info->>'name' as label,
          group_info->>'id' as value,
          json_build_object('id', group_info->>'id') as tags
        from 
          groups
      EOQ
  }   

  input "media_source" {
    title = "media source"
    width = 3
    sql = <<EOQ
      with data(label, value) as (
      values
        ('www.nytimes.com', 'www.nytimes.com'),
        ('www.washingtonpost.com', 'www.washingtonpost.com'),
        ('www.theatlantic.com', 'www.theatlantic.com'),
        ('www.latimes.com', 'www.latimes.com'),
        ('en.wikipedia.org', 'en.wikipedia.org'),
        ('www.jstor.org', 'www.jstor.org'),
        ('chem.libretexts.org', 'chem.libretexts.org'),
        ('www.americanyawp.com', 'www.americanyawp.com')
      )
      select * from data
    EOQ
  }

  input "annotated_media_url" {
    args = [ 
      self.input.groups.value,
      var.search_limit,
      self.input.media_source.value
    ]
    title = "recently-annotated urls"    
    width = 6
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
  }

  table {
    title = "longest threads"
    type = "table"
    args = [ self.input.annotated_media_url.value]
    query = query.threads
  }  

  hierarchy {
    title = "conversations"
    args = [ 
      self.input.groups.value,
      var.search_limit,
      self.input.annotated_media_url.value
    ]
    query = query.conversational_data
  }

}





