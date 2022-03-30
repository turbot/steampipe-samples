# Overview

This demo uses [steampipe-plugin-googleworkspace](https://hub.steampipe.io/plugins/turbot/googleworkspace), specifically the [gmail_message](https://hub.steampipe.io/plugins/turbot/googleworkspace/tables/googleworkspace_gmail_message) table. As per the examples there, typical uses of the plugin rely on `query=` in the WHERE clause to leverage Gmail's advanced search syntax and thus limit results to what can be fetched quickly from the API. 

It's also possible, as shown here, to load an archive of messages into Steampipe and use Postgres capabilities -- extra columns, indexes, convenience functions -- to enable SQL analysis of the archive.

# See it in action

https://user-images.githubusercontent.com/46509/152876596-259d1e1f-27f8-48e6-a8ac-e26ab7d1a8b4.mp4


# Table

```
create table gmail as (
  select * from googleworkspace_gmail_message where user_id = 'judell@gmail.com
)
```

Note: [MaxConcurrency](https://github.com/turbot/steampipe-plugin-googleworkspace/blob/main/googleworkspace/table_googleworkspace_gmail_message.go#L52) was reduced from 50 to 5 to avoid API throttling.

# Columns and indexes

```
-- index id and sender email
create index gmail_id_idx on gmail (id);
create index gmail_sender_idx on gmail (sender_email);

-- add column for base-64-decoded body
alter table gmail add column body text;
update gmail set body = gmail_body (id);
create index gmail_body_idx on gmail using gin (to_tsvector('english', body));

-- add column for recipients
alter table gmail add column recipients text;
update gmail set recipients = gmail_to (id);
create index gmail_recipients_idx on gmail (recipients);
```


# Queries

```
-- messages with attachments from infoworld.com

with filtered as (
  select * from gmail
  where sender_email ~ 'infoworld.com'
  and has_attachments(id) 
  order by internal_date
)
select 
  gmail_hide_sender(id),
  jsonb_array_length(payload -> 'parts') - 1 as attachments,
  gmail_date(id), 
  gmail_subject(id)
from filtered;
```

```
-- sender domains with 'unsubscribe' in body

select distinct gmail_sender_domain(id)
from gmail 
where body ~* 'unsubscribe'
order by gmail_sender_domain
```

```
-- labels

with label_ids as (
  select id, jsonb_array_elements_text(label_ids) as label_id from gmail
)
select gmail_name_for_label_id(label_id), count(*) 
from label_ids
group by label_id
order by count desc
```

```
-- from me / from others

with me as (
  select id from gmail
  where sender_email = any ( array[
    'judell@mv.com', 
    'jon_udell@infoworld.com',
    'judell@gmail.com',
    'jon@jonudell.info',
    'udell@monad.net'
    ])
),
others as (
  select id from gmail g
  where not exists (
    select * from me m where m.id = g.id
  )
)
select 
  ( select count(*) from me ) as from_me,
  ( select count(*) from others ) as from_others;
```

```
--  from me by sender_email

with sender_emails as (
  select unnest( array[
    'judell@mv.com', 
    'jon_udell@infoworld.com',
    'judell@gmail.com',
    'jon@jonudell.info',
    'udell@top.monad.net'
  ]) as sender_email
)
select sender_email, count(*) 
from gmail g
join sender_emails using(sender_email)
group by sender_email
order by count desc
```

```
-- sender domain counts

select
  gmail_sender_domain(id),
  count(*)
from
  gmail
group by
  gmail_sender_domain
order by 
  count desc;
```

```
-- more than 10 recipients from domain

select
  gmail_recipient_count(id),
  gmail_hide_sender(id),
  gmail_date(id), 
  gmail_subject(id)
from
  gmail
where 
  gmail_sender_domain(id) ~ 'oreilly.com'
and 
  gmail_recipient_count(id) > 10
order by 
  gmail_recipient_count desc;
```

# Functions

```
create or replace function gmail_headers (_id text) returns table (header jsonb) as $$
  select jsonb_array_elements(payload->'headers') as headers
  from gmail
  where id = _id
$$ language sql;

create or replace function gmail_subject (id text) returns text as $$
  select header ->> 'value' 
  from  gmail_headers(id) 
  where header ->> 'name' = 'Subject'
$$ language sql;

create or replace function gmail_from (id text) returns text as $$
  select header ->> 'value'
  from gmail_headers(id)
  where header ->> 'name' = 'From'
$$ language sql;

create or replace function gmail_sender_domain(_id text) returns text as $$	
  select
    (regexp_matches(lower(sender_email), '@(.+$)'))[1] as domain
  from gmail
  where id = _id
$$ language sql;

create or replace function gmail_to (id text) returns text as $$
  select header ->> 'value'
  from gmail_headers(id)
  where header ->> 'name' = 'To'
$$ language sql immutable;

create or replace function gmail_date (id text) returns text as $$
  select substring(header ->> 'value' from 1 for 16)
  from gmail_headers(id)
  where header ->> 'name' = 'Date'
$$ language sql;

create or replace function gmail_hide_sender(_id text) returns text as $$	
  select
    regexp_replace(sender_email, '(.+)@(.+$)', '___@\2')
  from gmail
  where id = _id
$$ language sql;

create or replace function gmail_recipient_count(_id text) returns int as $$	
  with commas as (
    select regexp_matches(recipients, '>,', 'g') 
    from gmail
    where id = _id
  )
  select 
    count(*)::int
  from commas
$$ language sql;

create or replace function gmail_body (_id text) returns text as $$
  select convert_from(
    decode(
      -- https://stackoverflow.com/questions/24812139/base64-decoding-of-mime-email-not-working-gmail-api
      replace(replace(payload -> 'body' ->> 'data','-', '+'), '_', '/'),
      'base64'
    ),
    'UTF8'
  )
  from gmail
  where id = _id
$$ language sql;

create or replace function has_attachments (_id text) returns boolean as $$
  select jsonb_array_length(payload -> 'parts') > 0
  from gmail
  where id = _id
$$ language sql;

create or replace function gmail_labels () 
  returns table (label jsonb ) as $$
  -- from https://developers.google.com/gmail/api/reference/rest/v1/users.labels/list
  select jsonb_array_elements('[
		{ "id": "CHAT", "name": "CHAT" },
		{ "id": "SENT", "name": "SENT" },
		{ "id": "INBOX", "name": "INBOX" },
		{ "id": "IMPORTANT", "name": "IMPORTANT" },
		{ "id": "TRASH", "name": "TRASH" },
		{ "id": "DRAFT", "name": "DRAFT" },
		{ "id": "SPAM", "name": "SPAM" },
		{ "id": "CATEGORY_FORUMS", "name": "CATEGORY_FORUMS"  },
		{ "id": "CATEGORY_UPDATES", "name": "CATEGORY_UPDATES"  },
		{ "id": "CATEGORY_PERSONAL", "name": "CATEGORY_PERSONAL"  },
		{ "id": "CATEGORY_PROMOTIONS", "name": "CATEGORY_PROMOTIONS"  },
		{ "id": "CATEGORY_SOCIAL", "name": "CATEGORY_SOCIAL"  },
		{ "id": "STARRED", "name": "STARRED" },
		{ "id": "UNREAD", "name": "UNREAD"  },
		{ "id": "Label_17", "name": "elmcity" },
		{ "id": "Label_19", "name": "letters" },
		{ "id": "Label_22", "name": "radar" },
		{ "id": "Label_23", "name": "school" },
		{ "id": "Label_24", "name": "screencast" },
		{ "id": "Label_26", "name": "timO" },
		{ "id": "Label_27", "name": "toMe" },
		{ "id": "Label_28", "name": "travel" },
		{ "id": "Label_29", "name": "Notes"  },
		{ "id": "Label_30", "name": "heartbeat" }
    ]' :: jsonb)
$$ language sql;

create or replace function gmail_name_for_label_id (label_id text) returns text as $$
  select label ->> 'name'
  from gmail_labels()
  where label ->> 'id' = label_id
$$ language sql;
```

