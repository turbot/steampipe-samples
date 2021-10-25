"""
REPO = 'vscode'
ORG_REPO = 'microsoft/vscode'
ORG_LOGIN = 'microsoft'
COMPANY = 'microsoft'
COMMIT_URL_STUB =  f'https://github.com/microsoft/vscode/commits?author=' 
ISSUE_URL_STUB =  f'https://github.com/micosoft/vscode/issues?q=author:' 
EXCLUDE_FROM_EXTERNAL_COMMITS = "['octref','eamodio']"
EXCLUDE_FROM_EXTERNAL_ISSUES = "['ghost', 'octref', 'vscodeerrors', 'eamodio']"
"""

REPO = 'typescript'
ORG_REPO = 'microsoft/typescript'
ORG_LOGIN = 'microsoft'
COMPANY = 'microsoft'
COMMIT_URL_STUB =  f'https://github.com/microsoft/typescript/commits?author=' 
ISSUE_URL_STUB =  f'https://github.com/micosoft/typescript/issues?q=author:' 
EXCLUDE_FROM_EXTERNAL_COMMITS = "['CyrusNajmabadi','vladima','mhegazy','csigs']"
EXCLUDE_FROM_EXTERNAL_ISSUES = "['mhegazy','ghost']"

"""
To find "false externals":
- build the tables
- `select * from REPO_external_commit_counts` 
- `select * from REPO_external_issue_counts`
- look up those people on GitHub and elsewhere, put the names in the exclude arrays
- drop/rebuild tables derived from commits and issues
"""

def sql():
  return f"""
drop table if exists {REPO}_log;
create table {REPO}_log(time timestamp, event text);

drop table if exists {REPO}_org_members;
insert into {REPO}_log(time, event) values (now(), '{REPO}_org_members');
create table {REPO}_org_members as (
  select
    g.name,
    g.login,
    jsonb_array_elements_text(g.member_logins) as member_login
  from
    github_organization g
  where
    g.login = '{ORG_LOGIN}'
);

drop table if exists {REPO}_commits;
insert into {REPO}_log(time, event) values (now(), '{REPO}_commits');
create table {REPO}_commits as (
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
    g.repository_full_name = '{ORG_REPO}'
);

drop table if exists {REPO}_committers;
insert into {REPO}_log(time, event) values (now(), '{REPO}_committers');
create table {REPO}_committers as (
  with unordered as (
    select distinct
      c.repository_full_name,
      c.author_login
    from
      {REPO}_commits c
  )
  select
    *
  from 
    unordered
  order by
    lower(author_login)
);

drop table if exists {REPO}_committer_details;
insert into {REPO}_log(time, event) values (now(), '{REPO}_committer_details');
create table {REPO}_committer_details as (
  select
    g.login,
    g.name,
    g.company,
    g.email,
    g.twitter_username
  from
    github_user g
  join
    {REPO}_committers c 
  on 
    c.author_login = g.login
);

drop table if exists {REPO}_internal_committers;
insert into {REPO}_log(time, event) values (now(), '{REPO}_internal_committers');
create table {REPO}_internal_committers as (
  with by_membership as (
    select 
      *
    from    
      {REPO}_committers c 
    join
      {REPO}_org_members o
    on
      c.author_login = o.member_login
    order by
      c.author_login
  ),
  by_{REPO}_committer_details as (
    select 
      *
    from
      {REPO}_committer_details cd
    where
      cd.company ~* '{COMPANY}' or cd.email ~* '{COMPANY}'
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
      by_{REPO}_committer_details cd
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

drop table if exists {REPO}_internal_commits;
insert into {REPO}_log(time, event) values (now(), '{REPO}_internal_commits');
create table {REPO}_internal_commits as (
  select 
    *
  from    
    {REPO}_commits c
  join
    {REPO}_internal_committers i
  using
    (author_login)
);

drop table if exists {REPO}_internal_commit_counts;
insert into {REPO}_log(time, event) values (now(), '{REPO}_internal_commit_counts');
create table {REPO}_internal_commit_counts as (
  select 
    i.repository_full_name,
    i.author_login,
    count(*)
  from    
    {REPO}_internal_commits i
  group by
    i.repository_full_name,
    i.author_login
  order by
    count desc
);

drop table if exists {REPO}_external_committers;
insert into {REPO}_log(time, event) values (now(), '{REPO}_external_committers');
create table {REPO}_external_committers as (
  select 
    *
  from    
    {REPO}_committers c 
  where not exists (
    select
      *
    from 
      {REPO}_internal_committers i 
    where
      c.author_login = i.author_login
      or c.author_login = any ( array {EXCLUDE_FROM_EXTERNAL_COMMITS} )
  )
  order by
    c.author_login
);

drop table if exists {REPO}_external_commits;
insert into {REPO}_log(time, event) values (now(), '{REPO}_external_commits');
create table {REPO}_external_commits as (
  select 
    *
  from    
    {REPO}_commits c
  join
    {REPO}_external_committers i
  using
    (repository_full_name, author_login)
);

drop table if exists {REPO}_external_commit_counts;
insert into {REPO}_log(time, event) values (now(), '{REPO}_external_commit_counts');
create table {REPO}_external_commit_counts as (
  select 
    e.repository_full_name,
    e.author_login,
    count(*)
  from    
    {REPO}_external_commits e
  group by
    e.repository_full_name,
    e.author_login
  order by
    count desc
);

drop table if exists {REPO}_issues;
insert into {REPO}_log(time, event) values (now(), '{REPO}_issues');
create table {REPO}_issues as (
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
     repository_full_name = '{ORG_REPO}'
);

drop table if exists {REPO}_issue_filers;
insert into {REPO}_log(time, event) values (now(), '{REPO}_issue_filers');
create table {REPO}_issue_filers as (
  with unordered as (
    select distinct
      i.repository_full_name,
      i.author_login
    from
      {REPO}_issues i
  )
  select
    *
  from 
    unordered
  order by
    lower(author_login)
);

-- insert into {REPO}_log(time, event) values (now(), '{REPO}_issue_filer_details');
-- create table {REPO}_issue_filer_details as (
--  
--   impractical for vscode's 52K issue authors at 5K API calls/hr!'
--
--);

drop table if exists {REPO}_internal_issue_filers;
insert into {REPO}_log(time, event) values (now(), '{REPO}_internal_issue_filers');
create table {REPO}_internal_issue_filers as (
  select 
    *
  from    
    {REPO}_issue_filers i 
  join
    {REPO}_org_members o
  on
    i.author_login = o.member_login
  order by
    i.author_login
);

drop table if exists {REPO}_internal_issues;
insert into {REPO}_log(time, event) values (now(), '{REPO}_internal_issues');
create table {REPO}_internal_issues as (
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
    {REPO}_issues i
  join
    {REPO}_internal_issue_filers if
  on
    i.author_login = if.author_login
    and i.repository_full_name = if.repository_full_name
  order by author_login
);

drop table if exists {REPO}_internal_issue_counts;
insert into {REPO}_log(time, event) values (now(), '{REPO}_internal_issue_counts');
create table {REPO}_internal_issue_counts as (
  select 
    i.repository_full_name,
    i.author_login,
    count(*)
  from    
    {REPO}_internal_issues i
  group by
    i.repository_full_name,
    i.author_login
  order by
    count desc
);

drop table if exists {REPO}_external_issue_filers;
insert into {REPO}_log(time, event) values (now(), '{REPO}_external_issue_filers');
create table {REPO}_external_issue_filers as (
  with unfiltered as (
    select 
      *
    from    
      {REPO}_issue_filers i 
    -- use {REPO}_internal_committers as a proxy for {REPO}_internal_issue_filers, which
    -- would require 52K github_user calls (at 5K/hr)
    where not exists (
      select
        *
      from 
        {REPO}_internal_committers c
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
    not u.author_login = any ( array {EXCLUDE_FROM_EXTERNAL_ISSUES} )
);

drop table if exists {REPO}_external_issues;
insert into {REPO}_log(time, event) values (now(), '{REPO}_external_issues');
create table {REPO}_external_issues as (
  select 
    *
  from    
    {REPO}_issues i
  join
    {REPO}_external_issue_filers e
  using
    (repository_full_name, author_login)
);

drop table if exists {REPO}_external_issue_counts;
insert into {REPO}_log(time, event) values (now(), '{REPO}_external_issue_counts');
create table {REPO}_external_issue_counts as (
  select 
    e.repository_full_name,
    e.author_login,
    count(*)
  from    
    {REPO}_external_issues e
  group by
    e.repository_full_name,
    e.author_login
  order by
    count desc
);

drop table if exists {REPO}_external_contributors;
insert into {REPO}_log(time, event) values (now(), '{REPO}_external_contributors');
create table {REPO}_external_contributors as (
  select
    c.repository_full_name,
    c.author_login,
    c.count as {REPO}_commits,
    '{COMMIT_URL_STUB}' || c.author_login as commits_url,
    i.count as {REPO}_issues,
    '{ISSUE_URL_STUB}' || c.author_login as issues_url,
    cd.name,
    cd.company,
    cd.twitter_username
  from
    {REPO}_external_commit_counts c
  full join
    {REPO}_external_issue_counts i
  using
    (repository_full_name, author_login)
  join 
    {REPO}_committer_details cd 
  on 
    c.author_login = cd.login
  order by
    lower(c.author_login)
);

drop table if exists {REPO}_external_commit_timelines;
insert into {REPO}_log(time, event) values (now(), '{REPO}_external_commit_timelines');
create table {REPO}_external_commit_timelines as (
  with data as (
    select
      e.repository_full_name,
      e.author_login,
      min(c.author_date) as first,
      max(c.author_date) as last
    from
      {REPO}_external_contributors e
    join 
      {REPO}_commits c
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
"""

with open(f'{REPO}.sql', 'w') as f:
  f.write(sql())