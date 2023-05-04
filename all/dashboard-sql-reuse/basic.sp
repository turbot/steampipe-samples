dashboard "basic" {

  benchmark "tls_version_basic" {
    title         = "sample benchmark"
    children = [
      control.tls_whitehouse_basic,
      control.tls_steampipe_basic
    ]
  }  

  card {
    width = 3
    title = "whitehouse.gov"
    args = [ "whitehouse.gov" ]
    base = card.tls_card
  }

  card {
    width = 3
    title = "steampipe.io"
    args = [ "steampipe.io" ]
    base = card.tls_card
  }

  container {
    
    chart "tls_version_basic_whitehouse" {
      args = [ "whitehouse.gov" ]
      title = "whitehouse.gov"
      base = chart.tls_version_basic
      width = 6
    }  

    chart "tls_version_basic_steampipe" {
      args = [ "steampipe.io" ]
      title = "steampipe.io"
      base = chart.tls_version_basic
    }
      
  }

  container {

    table "tls_version_basic_whitehouse" {
      width = 6
      title = "whitehouse.gov"
      base = table.tls_table_basic
      args = [ "whitehouse.gov"]
    }  

    table "tls_version_basic_steampipe" {
      width = 6
      title = "steampipe.io"
      base = table.tls_table_basic
      args = [ "steampipe.io"]
    }  
  }

}

control "tls_whitehouse_basic" {
  args = [ "whitehouse.gov" ]
  title = "control.tls_whitehouse"
  query = query.tls_control_basic
}

control "tls_steampipe_basic" {
  args = [ "steampipe.io" ]
  title = "control.tls_steampipe"
  query = query.tls_control_basic
}

table "tls_table_basic" {
  sql = <<EOQ
    select 
      *
    from
      net_tls_connection
    where
      address = $1 || ':443'
      and handshake_completed
  EOQ
}

query "tls_control_basic" {
  sql = <<EOQ
    with data as (
      select 
        max(version) as max_version,
        address
      from
        net_tls_connection
      where
        address = $1 || ':443'
        and handshake_completed
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
  param "domain" {}
}

chart "tls_version_basic" {
  type = "donut"
  width = 6
  sql = <<EOT
    select
      version,
      count(*)
    from
      net_tls_connection
    where
      address = $1 || ':443'
      and handshake_completed
    group by
      version
    EOT
}  

card "tls_card" {
  width = 3
  sql = <<EOQ
    select 
      max(version)
    from 
      net_tls_connection
    where
      address = $1 || ':443'
      and handshake_completed
  EOQ
}



