dashboard "Media_Conversations" {

  tags = {
    service  = "Hypothesis"
  }

  container {

    text {
      width = 3
      value = <<EOT
[Home](${local.host}/hypothesis.dashboard.Home)
🞄
Media_Conversations
      EOT
    }

  }

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
    query = query.recently_annotated_urls
  }

  table {
    title = "longest threads"
    type = "table"
    args = [ 
      self.input.annotated_media_url.value,
      self.input.groups.value
    ]
    query = query.threads
    column "top_level_id" {
      href = "https://hypothes.is/a/{{.'top_level_id'}}"
    }

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





