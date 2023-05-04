dashboard "using_hcl_with" {

  tags = {
    service = "v18 examples"
  }

  text {
    value = <<EOQ
    EOQ
  }

  with "data" {
    query = query.data
  }

    container {
    width = 4

    text {
      value = <<EOQ
```
query "data" {
  value = <<EOQ
    with data(person, server) as (
      values
        ('jon', 'mastodon.social'),
        ('chris', 'infosec.exchange')
    )
    select
      *
    from
      data
```
  EOQ
}

    text {
      value = <<EOQ
```
  with "data" {
    query = query.data
  }
```
      EOQ
    }

  }

  container {
    width = 6

    table {
      title = "use query.data directly"    
      query = query.data
    }

    table {
      title = "use query.data via with.data, pass a single row"
      args = [ with.data.rows[0].person, with.data.rows[0].server ]
      sql = <<EOQ
        select 
          $1 as person,
          $2 as server
      EOQ
    }

    table {
      title = "use query.data via with.data, pass all rows, display as arrays of text"
      args = [ with.data.rows[*].person, with.data.rows[*].server ]
      sql = <<EOQ
        select 
          $1::text[] as person,
          $2::text[] as server
      EOQ
    }

    table {
      title = "use query.data via with.data, pass all rows, unnest the arrays to display rows"
      args = [ with.data.rows[*].person, with.data.rows[*].server ]
      sql = <<EOQ
        select 
          unnest($1::text[]) as person,
          unnest($2::text[]) as server
      EOQ
    }

  }

}

query "data" {
  sql = <<EOQ
    with data(person, server) as (
      values
        ('jon', 'mastodon.social'),
        ('chris', 'infosec.exchange')
    )
    select
      *
    from
      data
  EOQ
}

