dashboard "functional" {

  with "tls_connection" {
    sql = <<EOQ
      create or replace function public.tls_connection(domain text) returns setof net_tls_connection as $$
        select
          *
        from
          net_tls_connection
        where
          address = domain || ':443'
          and handshake_completed
      $$ language sql
    EOQ     
  }

  benchmark "tls_version_functional" {
    title         = "sample benchmark"
    children = [
      control.tls_whitehouse_functional,
      control.tls_steampipe_functional
    ]
  }  

  card {
    width = 3
    title = "whitehouse.gov"
    sql = <<EOQ
      select max(version) from tls_connection('whitehouse.gov')
    EOQ
  }

  card {
    width = 3
    title = "steampipe.io"
    sql = <<EOQ
      select max(version) from tls_connection('steampipe.io')
    EOQ
  }

  container {
    chart "tls_version_functional_whitehouse" {
      args = [ "whitehouse.gov" ]
      title = "whitehouse.gov"
      base = chart.tls_version_functional
      width = 6
    }  

    chart "tls_version_functional_steampipe" {
      args = [ "steampipe.io" ]
      title = "steampipe.io"
      base = chart.tls_version_functional
    }  
  }

  container {
    table "tls_version_functional_whitehouse" {
      title = "whitehouse.gov"
      width = 6
      sql = <<EOT
        select * from tls_connection('whitehouse.gov')
        EOT
    }  

    table "tls_version_functional_steampipe" {
      width = 6
      title = "steampipe.io"
      sql = <<EOT
        select * from tls_connection('steampipe.io')
      EOT
    }  
  }


}

control "tls_whitehouse_functional" {
  args = [ "whitehouse.gov" ]
  title = "control.tls_whitehouse"
  query = query.tls_control_functional
}

control "tls_steampipe_functional" {
  args = [ "steampipe.io" ]
  title = "control.tls_steampipe"
  query = query.tls_control_functional
}

query "tls_control_functional" {
  sql = <<EOQ
    with data as (
      select 
        max(version) as max_version,
        address
      from
        tls_connection($1)
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

chart "tls_version_functional" {
  type = "donut"
  width = 6
  sql = <<EOT
    select
      version,
      count(*)
    from
      tls_connection($1)
    group by
      version
    EOT
}  









