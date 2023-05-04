locals {
  tls_connection_sql = <<EOQ
    select
      *
    from
      net_tls_connection
    where
      address = '__DOMAIN__' || ':443'
      and handshake_completed
  EOQ

  tls_control_sql = <<EOQ
    with data as (
      __SELECT_STATEMENT__
      group by
        address
    )
    select
      address as resource,
      case
        when max_version >= 'TLS v1.2' then 'ok'
        else 'alarm'
      end as status,
      case
        when max_version >= 'TLS v1.2' then $1 || ' TLS max_version is compliant: ' || max_version
        else $1 || ' TLS version is NOT compliant: ' || max_version
      end as reason
    from
      data
  EOQ
}


dashboard "hcl" {

/*
  text "debug" {
    value = replace(
      replace(
        replace(
          replace(local.tls_control_sql, "__SELECT_STATEMENT__", local.tls_connection_sql),
          "__DOMAIN__",
          "$1"
        ),
        "*",
        "max(version) as max_version, address"
      ),
      "'$1'",
      "$1"
    )

  }
  */

  benchmark "tls_version_hcl" {
    title         = "sample benchmark"
    children = [
      control.tls_whitehouse,
      control.tls_steampipe
    ]
  }  

  card {
    width = 3
    title = "whitehouse.gov"
    sql = replace(
        replace(local.tls_connection_sql, "__DOMAIN__", "whitehouse.gov"),
        "*",
        " max(version) "
      )
  }  

  card {
    width = 3
    title = "steampipe.io"
    sql = replace(
        replace(local.tls_connection_sql, "__DOMAIN__", "steampipe.io"),
        "*",
        " max(version) "
      )
  }

  container {
    chart "tls_version_hcl_whitehouse" {
      args = [ "whitehouse.gov" ]
      title = "whitehouse.gov"
      base = chart.tls_version_hcl
      width = 6
    }  

    chart "tls_version_hcl_steampipe" {
      args = [ "steampipe.io" ]
      title = "steampipe.io"
      base = chart.tls_version_hcl
    }  
  }

  container {

    table "tls_version_hcl_whitehouse" {
      title = "whitehouse.gov"
      width = 6
      sql = replace(local.tls_connection_sql, "__DOMAIN__", "whitehouse.gov")
    }  

    table "tls_version_hcl_steampipe" {
      width = 6
      title = "steampipe.io"
      sql = replace(local.tls_connection_sql, "__DOMAIN__", "steampipe.io")
    }  
  }

}

control "tls_whitehouse" {
  args = [ "whitehouse.gov" ]
  title = "control.tls_whitehouse"
  query = query.tls_control_hcl
}

control "tls_steampipe" {
  args = [ "steampipe.io" ]
  title = "control.tls_steampipe"
  query = query.tls_control_hcl
}

query "tls_control_hcl" {
  sql = replace(
    replace(
      replace(
        replace(local.tls_control_sql, "__SELECT_STATEMENT__", local.tls_connection_sql),
        "__DOMAIN__",
        "$1"
      ),
      "*",
      "max(version) as max_version, address"
    ),
    "'$1'",
    "$1"
  )
}
  
chart "tls_version_hcl" {
  type = "donut"
  width = 6
  sql = replace(
    replace(
      replace(local.tls_connection_sql, "'__DOMAIN__'", "$1"),
      "completed",
      "completed group by version"
    ),
    "*",
    " version, count(*)"
  )
}  









