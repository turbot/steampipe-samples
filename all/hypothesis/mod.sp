mod "hypothesis" {
  title = "Hypothesis Insights"
}

variable "search_limit" {
  type = number
  default = 2000
}

locals {
  host = "http://localhost:9194"
}


/*

Advanced feature: histograms

variable "note_word_count_buckets" {
  type = number
  default = 7
}

variable "user_anno_count_buckets" {
  type = number
  default = 5
}


To "install" these functions, you can copy/paste one at a time into the `steampipe query` console. Or if you have `psql` installed then you can run it like so:

psql -h localhost -p 9193 -d steampipe -U steampipe

And then copy/paste all the functions at once into that console.

-----

create or replace function user_anno_counts(search_limit int, groupid text, search_uri text) returns table (value int) as $$
  with anno_counts as (
    select 
      username, 
      count(*)
    from 
      hypothesis_search
    where 
      query =  'limit=' || search_limit
      || '&group=' || groupid
      || case when search_uri = 'all' then '' else '&uri=' || search_uri end
    group by 
      username
  )
  select 
    count::int as value
  from 
    anno_counts;
$$ language sql;

create or replace function user_anno_counts(search_limit int, groupid text, search_uri text) returns table (value int) as $$
  with anno_counts as (
    select 
      username, 
      count(*)
    from 
      hypothesis_search
    where 
      query =  'limit=' || search_limit
      || '&group=' || groupid
      || case when search_uri = 'all' then '' else '&uri=' || search_uri end
    group by 
      username
  )
  select 
    count::int as value
  from 
    anno_counts
$$ language sql;

create or replace function note_word_counts(search_limit int, groupid text, search_uri text) returns table (value int) as $$
  with word_counts as (
    select 
      (select count(*)::int from regexp_matches(text, '\s+', 'g'))
    from 
      hypothesis_search
    where 
      query =  'limit=' || search_limit
      || '&group=' || groupid
      || case when search_uri = 'all' then '' else '&uri=' || search_uri end
  )
  select 
    count as value 
  from 
    word_counts
$$ language sql;

-- This is a variant of the `histogram` function from https://github.com/turbot/steampipe-samples/tree/main/all/histogram
-- It switches the language from plpgsql to plpython to handle the added complexity of passing params to the values_fn
-- See https://github.com/turbot/steampipe-samples/tree/main/all/github-traffic for details on using plpython

create or replace function histogram(search_limit int, groupid text, search_uri text, bucket_count int, values_fn text) 
  returns table(range int4range, count bigint) as $$
  sql = f"""
    with min_max as (
      select
        value, 
        ( select min(value) from {values_fn}('{search_limit}', '{groupid}', '{search_uri}') ),
        ( select max(value) from {values_fn}('{search_limit}', '{groupid}', '{search_uri}') )
      from 
        {values_fn}('{search_limit}', '{groupid}', '{search_uri}')
    ),
    buckets as (
      select
        value,
        width_bucket(
          value, 
          min,
          max,
          {bucket_count}
        ) as bucket
      from 
        min_max
      where
        max > min
      ),
      bucket_min_max as (
        select
          bucket,
          min(value),
          max(value)
        from
          buckets
        group by 
          bucket
      ),
      ranges as (
        select
          bucket,
          int4range(min, max, '[]') as range
        from bucket_min_max 
      )
      select 
        r.range,
        count(b.*)
      from ranges r join buckets b using (bucket)
      where r.range != 'empty'
      group by b.bucket, r.range
      order by b.bucket
    """
  return plpy.execute(sql)
$$ language plpython3u;

*/
