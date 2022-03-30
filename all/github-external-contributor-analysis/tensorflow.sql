
drop table if exists tensorflow_log;
create table tensorflow_log(time timestamp, event text);

drop table if exists tensorflow_org_members;
insert into tensorflow_log(time, event) values (now(), 'tensorflow_org_members');
create table tensorflow_org_members as (
  select
    g.name,
    g.login,
    jsonb_array_elements_text(g.member_logins) as member_login
  from
    github_organization g
  where
    g.login = 'tensorflow'
);

drop table if exists tensorflow_commits;
insert into tensorflow_log(time, event) values (now(), 'tensorflow_commits');
create table tensorflow_commits as (
  select
    g.repository_full_name,
    g.author_login,
    g.author_date,
    g.commit->'author'->>'email' as author_email,
    g.committer_login,
    g.committer_date
  from
    github_commit g
  where
    g.repository_full_name = 'tensorflow/tensorflow'
);

drop table if exists tensorflow_committers;
insert into tensorflow_log(time, event) values (now(), 'tensorflow_committers');
create table tensorflow_committers as (
  with unordered as (
    select distinct
      c.repository_full_name,
      c.author_login
    from
      tensorflow_commits c
  )
  select
    *
  from 
    unordered
  where
    author_login is not null
  order by
    lower(author_login)
);

drop table if exists tensorflow_committer_details;
insert into tensorflow_log(time, event) values (now(), 'tensorflow_committer_details');
create table tensorflow_committer_details as (
  select
    g.login,
    g.name,
    g.company,
    g.email,
    g.twitter_username
  from
    github_user g
  join
    tensorflow_committers c 
  on 
    c.author_login = g.login
);

drop table if exists tensorflow_internal_committers;
insert into tensorflow_log(time, event) values (now(), 'tensorflow_internal_committers');
create table tensorflow_internal_committers as (
  with by_membership as (
    select 
      *
    from    
      tensorflow_committers c 
    join
      tensorflow_org_members o
    on
      c.author_login = o.member_login
    order by
      c.author_login
  ),
  by_tensorflow_committer_details as (
    select 
      *
    from
      tensorflow_committer_details cd
    where
      cd.company ~* 'google' or cd.email ~* 'google'
    order by
      cd.login
  ),
  combined as (
    select
      m.author_login as m_login,
      cd.login as c_login
    from
      by_membership m
    full join 
      by_tensorflow_committer_details cd
    on
      m.author_login = cd.login
  ),
  merged as (
    select
      case
        when m_login is null then c_login
        else m_login 
      end as author_login
    from 
      combined
  )
  select
    *
  from
    merged
  order by
    lower(author_login)
);

drop table if exists tensorflow_internal_commits;
insert into tensorflow_log(time, event) values (now(), 'tensorflow_internal_commits');
create table tensorflow_internal_commits as (
  select 
    *
  from    
    tensorflow_commits c
  join
    tensorflow_internal_committers i
  using
    (author_login)
);

drop table if exists tensorflow_internal_commit_counts;
insert into tensorflow_log(time, event) values (now(), 'tensorflow_internal_commit_counts');
create table tensorflow_internal_commit_counts as (
  select 
    i.repository_full_name,
    i.author_login,
    count(*)
  from    
    tensorflow_internal_commits i
  group by
    i.repository_full_name,
    i.author_login
  order by
    count desc
);

drop table if exists tensorflow_external_committers;
insert into tensorflow_log(time, event) values (now(), 'tensorflow_external_committers');
create table tensorflow_external_committers as (
  select 
    *
  from    
    tensorflow_committers c 
  where not exists (
    select
      *
    from 
      tensorflow_internal_committers i 
    where
      c.author_login = i.author_login
      or c.author_login = any ( array [''] )
  )
  order by
    c.author_login
);

drop table if exists tensorflow_external_commits;
insert into tensorflow_log(time, event) values (now(), 'tensorflow_external_commits');
create table tensorflow_external_commits as (
  select 
    *
  from    
    tensorflow_commits c
  join
    tensorflow_external_committers i
  using
    (repository_full_name, author_login)
);

drop table if exists tensorflow_external_commit_counts;
insert into tensorflow_log(time, event) values (now(), 'tensorflow_external_commit_counts');
create table tensorflow_external_commit_counts as (
  select 
    e.repository_full_name,
    e.author_login,
    count(*)
  from    
    tensorflow_external_commits e
  group by
    e.repository_full_name,
    e.author_login
  order by
    count desc
);

drop table if exists tensorflow_issues;
insert into tensorflow_log(time, event) values (now(), 'tensorflow_issues');
create table tensorflow_issues as (
  select
    repository_full_name,
    author_login,
    issue_number,
    title,
    created_at,
    closed_at,
    state,
    comments,
    tags
  from
    github_issue
  where
     repository_full_name = 'tensorflow/tensorflow'
);

drop table if exists tensorflow_issue_filers;
insert into tensorflow_log(time, event) values (now(), 'tensorflow_issue_filers');
create table tensorflow_issue_filers as (
  with unordered as (
    select distinct
      i.repository_full_name,
      i.author_login
    from
      tensorflow_issues i
  )
  select
    *
  from 
    unordered
  order by
    lower(author_login)
);

-- insert into tensorflow_log(time, event) values (now(), 'tensorflow_issue_filer_details');
-- create table tensorflow_issue_filer_details as (
--  
--   impractical for vscode's 52K issue authors at 5K API calls/hr!'
--
--);

drop table if exists tensorflow_internal_issue_filers;
insert into tensorflow_log(time, event) values (now(), 'tensorflow_internal_issue_filers');
create table tensorflow_internal_issue_filers as (
  select 
    *
  from    
    tensorflow_issue_filers i 
  join
    tensorflow_org_members o
  on
    i.author_login = o.member_login
  order by
    i.author_login
);

drop table if exists tensorflow_internal_issues;
insert into tensorflow_log(time, event) values (now(), 'tensorflow_internal_issues');
create table tensorflow_internal_issues as (
  select 
    i.repository_full_name,
    lower(i.author_login) as author_login,
    i.issue_number,
    i.created_at,
    i.closed_at,
    i.comments,
    i.state,
    i.title,
    i.tags
  from    
    tensorflow_issues i
  join
    tensorflow_internal_issue_filers if
  on
    i.author_login = if.author_login
    and i.repository_full_name = if.repository_full_name
  order by author_login
);

drop table if exists tensorflow_internal_issue_counts;
insert into tensorflow_log(time, event) values (now(), 'tensorflow_internal_issue_counts');
create table tensorflow_internal_issue_counts as (
  select 
    i.repository_full_name,
    i.author_login,
    count(*)
  from    
    tensorflow_internal_issues i
  group by
    i.repository_full_name,
    i.author_login
  order by
    count desc
);

drop table if exists tensorflow_external_issue_filers;
insert into tensorflow_log(time, event) values (now(), 'tensorflow_external_issue_filers');
create table tensorflow_external_issue_filers as (
  with unfiltered as (
    select 
      *
    from    
      tensorflow_issue_filers i 
    -- use tensorflow_internal_committers as a proxy for tensorflow_internal_issue_filers, which
    -- would require 52K github_user calls (at 5K/hr)
    where not exists (
      select
        *
      from 
        tensorflow_internal_committers c
      where
        c.author_login = i.author_login
    )
    order by
      i.author_login
  )
  select
    *
  from 
    unfiltered u
  where
    not u.author_login = any ( array [''] )
);

drop table if exists tensorflow_external_issues;
insert into tensorflow_log(time, event) values (now(), 'tensorflow_external_issues');
create table tensorflow_external_issues as (
  select 
    *
  from    
    tensorflow_issues i
  join
    tensorflow_external_issue_filers e
  using
    (repository_full_name, author_login)
);

drop table if exists tensorflow_external_issue_counts;
insert into tensorflow_log(time, event) values (now(), 'tensorflow_external_issue_counts');
create table tensorflow_external_issue_counts as (
  select 
    e.repository_full_name,
    e.author_login,
    count(*)
  from    
    tensorflow_external_issues e
  group by
    e.repository_full_name,
    e.author_login
  order by
    count desc
);

drop table if exists tensorflow_external_contributors;
insert into tensorflow_log(time, event) values (now(), 'tensorflow_external_contributors');
create table tensorflow_external_contributors as (
  select
    c.repository_full_name,
    c.author_login,
    c.count as tensorflow_commits,
    'https://github.com/tensorflow/tensorflow/commits?author=' || c.author_login as commits_url,
    i.count as tensorflow_issues,
    'https://github.com/tensorflow/tensorflow/issues?q=author:' || c.author_login as issues_url,
    cd.name,
    cd.company,
    cd.twitter_username
  from
    tensorflow_external_commit_counts c
  full join
    tensorflow_external_issue_counts i
  using
    (repository_full_name, author_login)
  join 
    tensorflow_committer_details cd 
  on 
    c.author_login = cd.login
  order by
    lower(c.author_login)
);

drop table if exists tensorflow_external_commit_timelines;
insert into tensorflow_log(time, event) values (now(), 'tensorflow_external_commit_timelines');
create table tensorflow_external_commit_timelines as (
  with data as (
    select
      e.repository_full_name,
      e.author_login,
      min(c.author_date) as first,
      max(c.author_date) as last
    from
      tensorflow_external_contributors e
    join 
      tensorflow_commits c
    using (repository_full_name, author_login)
    group by 
      e.repository_full_name, e.author_login
  )
  select
    repository_full_name,
    author_login,
    to_char(first, 'YYYY-MM-DD') as first,
    to_char(last, 'YYYY-MM-DD') as last
  from
    data d
  where
    d.first != d.last
  order by 
    first, last
);
