-- this worked but our trial account expired
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