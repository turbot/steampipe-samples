mod "metasearch" {
}

query "metasearch" {
    sql = <<EOQ

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
        and query = $1
     
      union
      select
        'slack' as type,
        user_name || ' in #' || (channel ->> 'name')::text as source,
        to_char(timestamp, 'YYYY-MM-DD') as date,
        permalink as link,
        text as content
      from
        slack_search
      where
        query = 'in:#steampipe after:3/12/2022 ' || $1

      union 
      select
        'github_issue' as type,
        repository_full_name || ' ' || title as source,
        to_char(created_at, 'YYYY-MM-DD') as date,
        html_url as link,
        substring(body from 1 for 200) || '...' as content
      from
        github_search_issue
      where
        query = 'org:turbot in:body in:comments' || $1
      
      union
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
      where query = $1
      order by
        date desc
      limit 
        20
    EOQ
    param "search_term" {}    
}

dashboard "metasearch" {

  input "search_term" {
    type = "text"
    width = "4"
    title = "search term"
  }

  table {
    title = "search gmail + slack + github + zendesk"
    query = query.metasearch
    args = {
      "search_term" = self.input.search_term
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

