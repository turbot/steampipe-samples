mod "chart_formats" {
}


/*
create table data_column_format as 
  with data (region, buckets, vpcs) as (
    values 
      ('us-east-1', 10, 7),
      ('us-west-1', 11, 3)
    )
  select * from data
*/

/*
create table data_row_format as 
  with data (region, label, count) as (
    values 
      ('us-east-1', 'buckets', 10),
      ('us-east-1', 'vpcs', 7),
      ('us-west-1', 'buckets', 11),
      ('us-west-1', 'vpcs', 3)
    )
  select * from data
*/


dashboard "chart_formats" {

  title = "Steampipe charts: data formats"

  text {
    width = 4
    value = "See the [documentation](https://steampipe.io/docs/reference/mod-resources/chart#data-format) for details on chart data formats, and [this repo](https://github.com/turbot/steampipe-samples/blob/main/all/crosstab/mod.sp) for source code."
  }

  container {

    title = "Data can be provided in 2 formats. Either in classic Excel-like column format, where each series data is contained in its own column"

    table {
      width = 6
      sql = <<EOQ
        select * from data_column_format
      EOQ
    }

    chart {
      width = 6
      sql = <<EOQ
        select * from data_column_format
      EOQ
    }

  }

  container {

    title = "Alternatively, data can be provided with the series data in rows."

    
    table {
      width = 6
      sql = <<EOQ
        select * from data_row_format
      EOQ
    }

    container {
      width = 6

      container {
        text {
          value = "Steampipe automically transforms this data to the columnwise format."
        }
      }

      chart {
        sql = <<EOQ
          select * from data_row_format
        EOQ
      }
    }

  }

  container {
  
    title = "Row data crosstabbed using the Postgres 'crosstab' function."
    
    container {
      width = 6

      container {
        text {
          value = "If you want to materialize that transformation you can use the *crosstab* function provide by the Postgres [tablefunc](https://www.postgresql.org/docs/current/tablefunc.html) extension."
        }
      }

      table {
        query = query.crosstab
      }
    }

    chart {
      width = 6
        query = query.crosstab
    }

  }

}

query "crosstab" {
  sql = <<EOQ
    select * from crosstab (
      
      -- SQL snippet to select raw data for the pivot
      $$
        select * from data_row_format
      $$,

      -- SQL snippet to define categories
      $$
        select distinct label from data_row_format order by label
      $$
      )
      
      -- definition of the output table
      as table_def (
        region text,
        buckets numeric,
        vpcs numeric
    );
  EOQ
}
