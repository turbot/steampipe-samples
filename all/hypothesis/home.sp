dashboard "Home" {

  tags = {
    service  = "Hypothesis"
  }

  container {

    text {
      width = 3
      value = <<EOT
Home
🞄
[Media_Conversations](${local.host}/hypothesis.dashboard.Media_Conversations)
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
        group_info->>'id' as value
      from 
        groups
    EOQ
  }

  input "annotated_uris" {
    title = "Search all, or choose URL"
    width = 8
    args = [ 
      self.input.groups.value,
      var.search_limit
    ]
    sql = <<EOQ
      with anno_counts_by_uri as (
        select 
          count(*),
          uri,
          title,
          group_id
        from
          hypothesis_search
        where
          query = 'group=' || $1 || '&limit=' || $2
        group by
          uri, title, group_id
        order by 
          count desc
      )
      select
        $2::int as count,
        'all' as value,
        'all' as label,
        jsonb_build_object('group','all') as tags
      union
      select
        count,
        uri as value,
        count || ' | ' || title || ' | ' || uri as label,
        jsonb_build_object('group', group_id) as tags
      from 
        anno_counts_by_uri
      order by
        count desc
    EOQ
  }

  table {
    width = 6
    args = [
    var.search_limit,
    self.input.groups.value,
    self.input.annotated_uris.value
    ]
    sql = <<EOQ
    select 
      'limit=' || $1
      || '&group=' || $2
      || case when $3 = 'all' then '' else '&uri=' || $3 end
    as "api query"
    EOQ
    column "api query" {
      wrap = "all"
    }
  }

  table {
    width = 6
    args = [
    self.input.annotated_uris.value
    ]
    sql = <<EOQ
    select 
      $1 as url
    EOQ
    column "url" {
      href = "{{.'url'}}"
      wrap = "all"
    }
  }


  container {
    width = 12

    card {
      args = [
        var.search_limit,
        self.input.groups.value,
        self.input.annotated_uris.value
      ]
      width = 3
      sql   = <<EOQ
        select count(*) as "matching annos"
      from
        hypothesis_search
      where query = 'limit=' || $1
        || '&group=' || $2
        || case when $3 = 'all' then '' else '&uri=' || $3 end
      EOQ
    }

    card {
      args = [
        var.search_limit,
        self.input.groups.value,
        self.input.annotated_uris.value
      ]
      width = 3
      sql   = <<EOQ
        select count( distinct username) as "annotators"
      from
        hypothesis_search
      where query = 'limit=' || $1
        || '&group=' || $2
        || case when $3 = 'all' then '' else '&uri=' || $3 end
      EOQ
    }

    card {
      args = [
        var.search_limit,
        self.input.groups.value,
        self.input.annotated_uris.value
      ]
      width = 3
      sql   = <<EOQ
        select substring(min(created) from 1 for 10) as "first anno"
      from
        hypothesis_search
      where query = 'limit=' || $1
        || '&group=' || $2
        || case when $3 = 'all' then '' else '&uri=' || $3 end
      EOQ
    }

    card {
      args = [ 
        var.search_limit,
        self.input.groups.value,
        self.input.annotated_uris.value
      ]
      width = 3
      sql   = <<EOQ
        select substring(max(created) from 1 for 10) as "last anno"
      from
        hypothesis_search
      where query = 'limit=' || $1
        || '&group=' || $2
        || case when $3 = 'all' then '' else '&uri=' || $3 end
      EOQ
    }
  }

  container {
    width = 12

    chart {
      args = [ 
        var.search_limit,
        self.input.groups.value,
        self.input.annotated_uris.value
      ]
      title = "top annotators"
      type  = "donut"
      width = 4
      query = query.top_annotators
    }

    chart {
      args = [ 
        var.search_limit,
        self.input.groups.value,
        self.input.annotated_uris.value
      ]
      title = "top domains"
      type  = "donut"
      width = 4
      query = query.top_domains
    }

    chart {
      args = [ 
        var.search_limit,
        self.input.groups.value,
        self.input.annotated_uris.value
      ]
      type  = "donut"
      title = "top tags"
      width = 4
      query = query.top_tags
    }
  }

  container {
    width = 12

    table {
      args = [ 
        var.search_limit,
        self.input.groups.value,
        self.input.annotated_uris.value
      ]
      title = "top annotators"
      type  = "donut"
      width = 4
      query = query.top_annotators
    }

    table {
      args = [ 
        var.search_limit,
        self.input.groups.value,
        self.input.annotated_uris.value
      ]
      title = "top domains"
      type  = "donut"
      width = 4
      query = query.top_domains
    }

    table {
      args = [ 
        var.search_limit,
        self.input.groups.value,
        self.input.annotated_uris.value
      ]
      type  = "donut"
      title = "top tags"
      width = 4
      query = query.top_tags
    }
  }

  container {
    width = 12

    table {
      args = [ 
        var.search_limit,
        self.input.groups.value,
        self.input.annotated_uris.value
      ]
      title = "top urls"
      width = 12
      sql   = <<EOT
        select 
          count(*) as notes,
          title,
          uri
        from 
            hypothesis_search
        where query = 'limit=' || $1
          || '&group=' || $2
          || case when $3 = 'all' then '' else '&uri=' || $3 end
        group by 
          uri, title
        order by
          notes desc
        limit 10
      EOT
      column "uri" {
        wrap = "all"
      }
      column "title" {
        wrap = "all"
      }
    }

    chart {
      args = [ 
        var.search_limit,
        self.input.groups.value,
        self.input.annotated_uris.value
      ]
      type = "table"
      title = "top tags and taggers"
      width = 12
      sql   = <<EOT
        with user_tag as (
          select username, jsonb_array_elements_text(tags) as tag
          from 
            hypothesis_search
          where query = 'limit=' || $1
            || '&group=' || $2
            || case when $3 = 'all' then '' else '&uri=' || $3 end
        ),
        top_tags as (
          select 
            tag,
            count(*) as tags
        from user_tag
        group by tag
        order by tags desc
        limit 10
        )
        select 
          tag, tags as occurrences, array_to_string(array_agg(distinct username), ', ') as taggers
        from top_tags t join user_tag u using (tag)
        group by t.tag, t.tags
        order by tags desc
      EOT
    }

  }

  container {

    table {
      title = "longest threads"
      type = "table"
      args = [ 
        self.input.annotated_uris.value,
        self.input.groups.value,
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
        self.input.annotated_uris.value
      ]
      query = query.conversational_data
    }  


  }


/* 

Advanced feature: histograms

  container {
    width = 12

    container {
      width = 6
      chart {
        args = [ 
          var.search_limit,
          self.input.groups.value,
          self.input.annotated_uris.value
        ]      
        title = "annotations in buckets by word count"
        type  = "column"
        axes {
          x {
            title {
              value = "word count buckets"
              align = "center"
            }
          }
          y {
            title {
              value = "notes in bucket"
              align = "center"
            }
          }
        }
        sql = <<EOQ
          select * from histogram (
            $1,
            $2,
            $3,
            ${var.note_word_count_buckets}, 
            'note_word_counts'
          )
        EOQ
      }
    }

    container {
      width = 6
      chart {
        args = [ 
          var.search_limit,
          self.input.groups.value,
          self.input.annotated_uris.value
        ]           
        title = "users in buckets by annotation count"
        type  = "column"
        axes {
          x {
            title {
              value = "user anno count buckets"
              align = "center"
            }
          }
          y {
            title {
              value = "users in bucket"
              align = "center"
            }
          }
        }

        sql = <<EOQ
          select * from histogram (
            $1,
            $2,
            $3,
            ${var.user_anno_count_buckets}, 
            'user_anno_counts'
          )
        EOQ
      }
    }

  }

*/

}


