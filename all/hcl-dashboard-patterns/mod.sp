mod "hcl_dashboard_patterns" {
}

locals {
  foo = "bar"
}

query "plain_query_object" {
  sql = "select 'plain_query_object' as data" 
}

query "interpolated_query_object" {
  sql = "select 'interpolated_query_object: ${local.foo}' as data" 
}


query "parameterized_query_object" {
  sql = "select 'parameterized_query_object: ' || $1 as data"
  param "param" {}
}

dashboard "hcl_dashboard_patterns" {

  container {
    title = "inline table"

    table {
      width = 4
      title = "plain inline query"
      sql = "select 'plain inline query' as data"
    }

    table {
      width = 4
      title = "interpolated inline query"
      sql = "select 'interpolated inline query: ${local.foo}' as data"
    }

    table {
      width = 4
      title = "parameterized inline query"
      sql = "select 'parameterized inline query: ' || $1 as data"
      args = [        
        local.foo
      ]
      // This is not an error, but has no effect,
      // unless `args` is omitted, then it's an error.
      param "param" {} 
      
      // This will fail, yielding -> parameterized inline query: $1
      // sql = "select 'parameterized inline query: $1' as data"

    }

  }

  container {
    title = "query object"

    table {
      width = 4
      title = "plain query object"
      query = query.plain_query_object
    }

    table {
      width = 4
      title = "interpolated query object"
      query = query.interpolated_query_object
    }

    table {
      width = 4
      title = "parameterized query object"
      query = query.parameterized_query_object
      args = [
          local.foo
      ]
      // This is not an error, but has no effect.
      param "param" {} 
    }
   
  }

  container {
    title = "query file"
 
    table {
      width = 4
      title = "use plain sql file"
      sql = query.plain_sql_file.sql
    }

    table {
      width = 4
      title = "use interpolated sql file (fail)"
      sql = query.interpolated_sql_file.sql
    }

    table {
      width = 4
      title = "use parameterized sql file"
      sql = query.parameterized_sql_file.sql
      args = [
        local.foo
      ]
      // This is not an error, but has no effect.
      param "param" {}
    }

  }

}