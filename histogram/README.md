# Overview

Postgres provides a couple of functions -- `width_bucket` and `int4range` -- that we can  use in combination to make histograms, as shown by [Dimitri Fontaine](https://tapoueh.org/blog/2014/02/postgresql-aggregates-and-histograms/). [This example](./histogram/README.md) adapts that approach to Steampipe.

# Basic: Using values provided by a hardcoded query

Here's an example that uses the [Hypothesis](https://hub.steampipe.io/plugins/hypothesis) plugin. The setup: install the plugin, then cache 10k annotations in a table.

```
steampipe plugin install hypothesis

steampipe query

> create table hypothesis as select * from hypothesis_search where query = 'limit=10000'
```

Here's a histogram that uses Dimitri's technique to bucket users by the number of annotations they've created.

```
with values as (
    with anno_counts as (
    select username, count(*)
        from hypothesis
        group by username
    )
    select count::int as value from anno_counts
    where count < 1000 -- exclude bots
),

buckets as (
    select
        value,
        width_bucket(
            value, 
            (select min(value) from values ),
            (select max(value) from values ),
            10
        ) as bucket
        from values
    ),

min_max as (
    select
        bucket,
        min(value),
        max(value)
    from
        buckets
    group by bucket
),

ranges as (
    select
        bucket,
        int4range(min, max, '[]') as range
    from min_max 
    )
select 
    r.range,
    count(b.*)
from ranges r join buckets b using (bucket)
group by b.bucket, r.range
order by b.bucket;
```

```
+-----------+-------+
| range     | count |
+-----------+-------+
| [1,18)    | 1061  |
| [18,35)   | 38    |
| [35,52)   | 13    |
| [55,67)   | 5     |
| [79,80)   | 1     |
| [94,98)   | 2     |
| [113,117) | 3     |
| [137,146) | 3     |
| [167,168) | 1     |
| [168,169) | 1     |
+-----------+-------+
```

# Advanced: Using values provide by a function

Suppose we instead want to bucket annotations by word count. We can repeat the above query with a different `values` CTE.

```
with values as (
  with word_counts as (
    select 
      (select count(*)::int from regexp_matches(text, '\s+', 'g'))
    from hypothesis
  )
  select count as value from word_counts
  where count < 200 -- exclude outliers
),
... as above
```

```
+-----------+-------+
| range     | count |
+-----------+-------+
| [0,20)    | 4305  |
| [20,40)   | 4227  |
| [40,60)   | 548   |
| [60,80)   | 243   |
| [80,100)  | 149   |
| [100,120) | 108   |
| [120,140) | 62    |
| [140,160) | 40    |
| [160,179) | 22    |
| [180,198) | 18    |
| [199,200) | 1     |
+-----------+-------+
```

And there are a million other things we might want to histogram, using the Hypothesis plugin or another [Steampipe plugin](https://hub.steampipe.io/plugins). We'd rather not use copy/paste to duplicate this query many times, swapping in a different `values` CTE each time. This would be much nicer.

```
select * from histogram(10, 'user_anno_counts') -- user annotation counts in 10 buckets

select * from histogram(5, 'note_word_counts') -- annotation word counts in 5 buckets
```

For starters, let's write a couple of functions to encapsulate the two `values` CTEs.

```
create function user_anno_counts() returns table (value int) as $$
  with anno_counts as (
    select username, count(*)
      from hypothesis
      group by username
  )
  select count::int as value from anno_counts
  where count < 1000
$$ language sql;
```

```
select * from user_anno_counts() limit 10;
+-------+
| value |
+-------+
| 3     |
| 1     |
| 1     |
| 2     |
| 3     |
| 7     |
| 2     |
| 1     |
| 5     |
| 1     |
+-------+
```
```
create function note_word_counts() returns table (value int) as $$
  with word_counts as (
    select 
      (select count(*)::int from regexp_matches(text, '\s+', 'g'))
    from hypothesis
  )
  select count as value from word_counts
  where count < 200;
$$ language sql;
```
```
select * from note_word_counts() limit 10;
+-------+
| value |
+-------+
| 35    |
| 98    |
| 11    |
| 64    |
| 26    |
| 80    |
| 63    |
| 0     |
| 48    |
| 23    |
+-------+
```

Now we can write the function `histogram(bucket_count, values_fn)`.

```
create or replace function histogram(bucket_count int, values_fn text) 
  returns table(range int4range, count bigint) as $$
  begin
    return query execute format($f$
      with buckets as (
        select
          value,
            width_bucket(
              value, 
              (select min(value) from %I() ),
              (select max(value) from %I() ),
              $1
            ) as bucket
         from %I()
        ),
      min_max as (
        select
          bucket,
          min(value),
          max(value)
        from
          buckets
        group by bucket
      ),
      ranges as (
        select
          bucket,
          int4range(min, max, '[]') as range
        from min_max 
      )
      select 
        r.range,
        count(b.*)
      from ranges r join buckets b using (bucket)
      where r.range != 'empty'
      group by b.bucket, r.range
      order by b.bucket
      $f$, values_fn, values_fn, values_fn)
      using bucket_count;
  end;
$$ language plpgsql;
```

Things to note:

- The other functions use Postgres' basic `sql` language. This one uses `plpgsl` which can dynamically build and run queries. 

- The function body is wrapped in a "dollar-quoted" chunk delimited by `$$`, as is typical. The argument to `format` is nested within the body using an alternate delimiter `$f$`. (It could also be, e.g., `$format$`.)

- The `bucket_count` argument, which is received as the positional parameter `$1`, is passed into the function by way of `using bucket_count`.

- The `values_fn` is passed as arguments to `format`, and received using `%I` which treats the argument as a SQL identifier.

- Yes, this is confusing. 

But now we can do this.

```
select * from histogram(10, 'user_anno_counts')
+-----------+-------+
| range     | count |
+-----------+-------+
| [1,18)    | 1061  |
| [18,35)   | 38    |
| [35,52)   | 13    |
| [55,67)   | 5     |
| [79,80)   | 1     |
| [94,98)   | 2     |
| [113,117) | 3     |
| [137,146) | 3     |
| [167,168) | 1     |
| [168,169) | 1     |
+-----------+-------+
```

And this.

```
> select * from histogram(5, 'note_word_counts')
+-----------+-------+
| range     | count |
+-----------+-------+
| [0,40)    | 8532  |
| [40,80)   | 791   |
| [80,120)  | 257   |
| [120,160) | 102   |
| [160,198) | 40    |
| [199,200) | 1     |
+-----------+-------+
```

It's easy to write functions like `user_anno_counts` and `note_word_counts`. Any such function can be passed to `histogram`.


