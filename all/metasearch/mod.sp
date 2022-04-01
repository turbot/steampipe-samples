mod "metasearch" {
}

query "metasearch" {
    sql = <<EOQ
      with gmail as (
        select
          'gmail' as type,
          sender_email as source,
          to_char(internal_date, 'YYYY-MM-DD') as date,
          'https://mail.google.com/mail/u/0/#search/%22' || (regexp_match(snippet, '(^.{20,20}[^\s]+)'))[1] || '%22' as link,
                --  still unhandled, e.g. "Here&#39;s the signing request"
          snippet as content
        from
          googleworkspace_gmail_message
        where
          user_id = 'judell@gmail.com'
          and $1 ~ 'gmail'
          and query = $2
          limit $3
      ),
      slack as (
        select
          'slack' as type,
          user_name || ' in #' || (channel ->> 'name')::text as source,
          to_char(timestamp, 'YYYY-MM-DD') as date,
          permalink as link,
          text as content
        from
          slack_search
        where
          $1 ~ 'slack'
          and query = 'in:#steampipe after:3/12/2022 ' || $2
        limit $3
      ),
      github_issue as (
        select
          'github_issue' as type,
          repository_full_name || ' ' || title as source,
          to_char(created_at, 'YYYY-MM-DD') as date,
          html_url as link,
          substring(body from 1 for 200) || '...' as content
        from
          github_search_issue
        where
          $1 ~ 'github_issue'
          and query = 'org:turbot in:body in:comments ' || $2
        limit $3
      ),
      zendesk as (      
        select
          'zendesk' as type,
          result -> 'via' ->> 'channel' || ': ' || 
            ( select name from zendesk_user where id::text = result ->> 'submitter_id' )
          as source,
          substring(result ->> 'created_at' from 1 for 10) as date,
          'https://turbothelp.zendesk.com/agent/tickets/' || (result ->> 'id')::text as link,
          result ->> 'subject' as content
        from 
          zendesk_search 
        where 
          $1 ~ 'zendesk'
          and query = $2
        limit $3
      )

      select * from gmail
      union 
      select * from slack
      union 
      select * from github_issue
      union 
      select * from zendesk

      order by
        date desc
    EOQ
    param "sources" {}
    param "search_term" {}
    param "max_per_source" {}
}

dashboard "metasearch" {

  input "sources" {
    title = "sources"
    type = "multiselect"
    width = 4
    option "gmail" {}
    option "slack" {}   
    option "github_issue" {}
    option "zendesk" {}
  }  

  input "search_term" {
    type = "text"
    width = "4"
    title = "search term"
  }

  input "max_per_source" {
    title = "max per source"
    width = 2
    option "5" {}
    option "10" {}   
    option "20" {}
  }  

  table {
    title = "search gmail + slack + github + zendesk"
    query = query.metasearch
    args = {
      "sources" = self.input.sources,
      "search_term" = self.input.search_term,
      "max_per_source" = self.input.max_per_source
    }
    column "source" {
      wrap = "all"
    }
    column "link" {
      wrap = "all"
    }
    column "content" {
      wrap = "all"
    }
  }

}

