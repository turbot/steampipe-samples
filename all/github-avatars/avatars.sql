create or replace function avatars(repo text) returns table (
    repo text, 
    src text, 
    alt text, 
    count bigint
  )  as $$
  with committers as (
    select
      author_login,
      count(*)
    from
     github_commit
    where
      repository_full_name = $1
    group by
      author_login
  )
  select
    repo,
    u.avatar_url as src,
    c.author_login as alt,
    c.count
  from
    committers c
    join github_user u on c.author_login = u.login
  order by
    lower(author_login);
$$ language sql;

-- alias spsql="psql -h localhost -p 9193 -d steampipe -U steampipe"
--  spsql -c "copy (select * from avatars('turbot/steampipe-plugin-oci')) to stdout with delimiter ',' csv header" > avatars.csv;