
drop table if exists vscode_log;
create table vscode_log(time timestamp, event text);

drop table if exists vscode_org_members;
insert into vscode_log(time, event) values (now(), 'vscode_org_members');
create table vscode_org_members as (
  select
    g.name,
    g.login,
    jsonb_array_elements_text(g.member_logins) as member_login
  from
    github_organization g
  where
    g.login = 'microsoft'
);

drop table if exists vscode_commits;
insert into vscode_log(time, event) values (now(), 'vscode_commits');
create table vscode_commits as (
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
    g.repository_full_name = 'microsoft/vscode'
);

drop table if exists vscode_committers;
insert into vscode_log(time, event) values (now(), 'vscode_committers');
create table vscode_committers as (
  with unordered as (
    select distinct
      c.repository_full_name,
      c.author_login
    from
      vscode_commits c
  )
  select
    *
  from 
    unordered
  order by
    lower(author_login)
);

drop table if exists vscode_committer_details;
insert into vscode_log(time, event) values (now(), 'vscode_committer_details');
create table vscode_committer_details as (
  select
    g.login,
    g.name,
    g.company,
    g.email,
    g.twitter_username
  from
    github_user g
  join
    vscode_committers c 
  on 
    c.author_login = g.login
);

drop table if exists vscode_internal_committers;
insert into vscode_log(time, event) values (now(), 'vscode_internal_committers');
create table vscode_internal_committers as (
  with by_membership as (
    select 
      *
    from    
      vscode_committers c 
    join
      vscode_org_members o
    on
      c.author_login = o.member_login
    order by
      c.author_login
  ),
  by_vscode_committer_details as (
    select 
      *
    from
      vscode_committer_details cd
    where
      cd.company ~* 'microsoft' or cd.email ~* 'microsoft'
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
      by_vscode_committer_details cd
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

drop table if exists vscode_internal_commits;
insert into vscode_log(time, event) values (now(), 'vscode_internal_commits');
create table vscode_internal_commits as (
  select 
    *
  from    
    vscode_commits c
  join
    vscode_internal_committers i
  using
    (author_login)
);

drop table if exists vscode_internal_commit_counts;
insert into vscode_log(time, event) values (now(), 'vscode_internal_commit_counts');
create table vscode_internal_commit_counts as (
  select 
    i.repository_full_name,
    i.author_login,
    count(*)
  from    
    vscode_internal_commits i
  group by
    i.repository_full_name,
    i.author_login
  order by
    count desc
);

drop table if exists vscode_external_committers;
insert into vscode_log(time, event) values (now(), 'vscode_external_committers');
create table vscode_external_committers as (
  select 
    *
  from    
    vscode_committers c 
  where not exists (
    select
      *
    from 
      vscode_internal_committers i 
    where
      c.author_login = i.author_login
      or c.author_login = any ( array ['octref','eamodio'] )
  )
  order by
    c.author_login
);

drop table if exists vscode_external_commits;
insert into vscode_log(time, event) values (now(), 'vscode_external_commits');
create table vscode_external_commits as (
  select 
    *
  from    
    vscode_commits c
  join
    vscode_external_committers i
  using
    (repository_full_name, author_login)
);

drop table if exists vscode_external_commit_counts;
insert into vscode_log(time, event) values (now(), 'vscode_external_commit_counts');
create table vscode_external_commit_counts as (
  select 
    e.repository_full_name,
    e.author_login,
    count(*)
  from    
    vscode_external_commits e
  group by
    e.repository_full_name,
    e.author_login
  order by
    count desc
);

drop table if exists vscode_issues;
insert into vscode_log(time, event) values (now(), 'vscode_issues');
create table vscode_issues as (
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
     repository_full_name = 'microsoft/vscode'
);

drop table if exists vscode_issue_filers;
insert into vscode_log(time, event) values (now(), 'vscode_issue_filers');
create table vscode_issue_filers as (
  with unordered as (
    select distinct
      i.repository_full_name,
      i.author_login
    from
      vscode_issues i
  )
  select
    *
  from 
    unordered
  order by
    lower(author_login)
);

-- insert into vscode_log(time, event) values (now(), 'vscode_issue_filer_details');
-- create table vscode_issue_filer_details as (
--  
--   impractical for vscode's 52K issue authors at 5K API calls/hr!'
--
--);

drop table if exists vscode_internal_issue_filers;
insert into vscode_log(time, event) values (now(), 'vscode_internal_issue_filers');
create table vscode_internal_issue_filers as (
  select 
    *
  from    
    vscode_issue_filers i 
  join
    vscode_org_members o
  on
    i.author_login = o.member_login
  order by
    i.author_login
);

drop table if exists vscode_internal_issues;
insert into vscode_log(time, event) values (now(), 'vscode_internal_issues');
create table vscode_internal_issues as (
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
    vscode_issues i
  join
    vscode_internal_issue_filers if
  on
    i.author_login = if.author_login
    and i.repository_full_name = if.repository_full_name
  order by author_login
);

drop table if exists vscode_internal_issue_counts;
insert into vscode_log(time, event) values (now(), 'vscode_internal_issue_counts');
create table vscode_internal_issue_counts as (
  select 
    i.repository_full_name,
    i.author_login,
    count(*)
  from    
    vscode_internal_issues i
  group by
    i.repository_full_name,
    i.author_login
  order by
    count desc
);

drop table if exists vscode_external_issue_filers;
insert into vscode_log(time, event) values (now(), 'vscode_external_issue_filers');
create table vscode_external_issue_filers as (
  with unfiltered as (
    select 
      *
    from    
      vscode_issue_filers i 
    -- use vscode_internal_committers as a proxy for vscode_internal_issue_filers, which
    -- would require 52K github_user calls (at 5K/hr)
    where not exists (
      select
        *
      from 
        vscode_internal_committers c
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
    not u.author_login = any ( array ['ghost', 'octref', 'vscodeerrors', 'eamodio'] )
);

drop table if exists vscode_external_issues;
insert into vscode_log(time, event) values (now(), 'vscode_external_issues');
create table vscode_external_issues as (
  select 
    *
  from    
    vscode_issues i
  join
    vscode_external_issue_filers e
  using
    (repository_full_name, author_login)
);

drop table if exists vscode_external_issue_counts;
insert into vscode_log(time, event) values (now(), 'vscode_external_issue_counts');
create table vscode_external_issue_counts as (
  select 
    e.repository_full_name,
    e.author_login,
    count(*)
  from    
    vscode_external_issues e
  group by
    e.repository_full_name,
    e.author_login
  order by
    count desc
);

drop table if exists vscode_external_contributors;
insert into vscode_log(time, event) values (now(), 'vscode_external_contributors');
create table vscode_external_contributors as (
  select
    c.repository_full_name,
    c.author_login,
    c.count as vscode_commits,
    'https://github.com/microsoft/vscode/commits?author=' || c.author_login as commits_url,
    i.count as vscode_issues,
    'https://github.com/micosoft/vscode/issues?q=author:' || c.author_login as issues_url,
    cd.name,
    cd.company,
    cd.twitter_username
  from
    vscode_external_commit_counts c
  full join
    vscode_external_issue_counts i
  using
    (repository_full_name, author_login)
  join 
    vscode_committer_details cd 
  on 
    c.author_login = cd.login
  order by
    lower(c.author_login)
);

drop table if exists vscode_external_commit_timelines;
insert into vscode_log(time, event) values (now(), 'vscode_external_commit_timelines');
create table vscode_external_commit_timelines as (
  with data as (
    select
      e.repository_full_name,
      e.author_login,
      min(c.author_date) as first,
      max(c.author_date) as last
    from
      vscode_external_contributors e
    join 
      vscode_commits c
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
