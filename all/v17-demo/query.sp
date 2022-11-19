query "repos_use_semantic_versioning" {
  sql = <<EOQ
    with repo_full_names as (
      select 
        full_name,
        html_url
      from
        github_my_repository
      where
        full_name ~ $1
      ),
      repo_tags as (
      select distinct on (r.full_name, t.name)
        r.full_name,
        t.name as tag_name,
        r.html_url || '@' || t.name as url_with_tag,
        t.commit_sha
      from        
        github_tag t
      join
        repo_full_names r
      on
        r.full_name = t.repository_full_name
        and r.full_name ~ $1
      ),
      dated_repo_tag_shas as (
        select
          c.committer_date,
          c.sha
      from
        github_commit c
      where 
        c.sha in (select commit_sha from repo_tags)
        and c.repository_full_name in (select full_name from repo_tags)
      ),
      dated_releases as (
        select 
          full_name,
          tag_name,
          url_with_tag,
          committer_date
        from
          repo_tags r 
        join
          dated_repo_tag_shas d
        on
          r.commit_sha = d.sha
      )
      select distinct on (full_name) 
        url_with_tag as resource,
          case
            when tag_name ~ ( $2 || '$') then 'ok'
            when tag_name ~ $2 then 'info'
            else 'alarm'
            end as status,
          url_with_tag as reason,
          tag_name,
          committer_date
      from
          dated_releases d
      order by full_name, committer_date desc
  EOQ
  param "repo_pattern" {}
  param "semver_pattern" {}
}
