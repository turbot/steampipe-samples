mod "local" {
  title = "my-aws-thrifty"
  require {
    mod "github.com/turbot/steampipe-mod-aws-thrifty" {
      version = "latest"
    }
  }
}

locals {
  hub_path = "https://hub.steampipe.io/mods/turbot/aws_thrifty"
}

dashboard "All-controls-with-descriptions" {
  table {
    sql = <<EOQ
      with controls as (
        select
          (regexp_matches(source_definition, 'query\.([^\.]+)'))[1] as query,
          resource_name as control_name,
          tags ->> 'service' as service,
          (regexp_matches(source_definition, 'description\s*=\s*"([^"]+)'))[1] as description
        from
          steampipe_control
        order by
          query, control_name
      )
      select 
        service,
        control_name,
        query,
        description
      from
        controls
      order by
        service, control_name
    EOQ
    column "control_name" {
      href =  "${local.hub_path}{{'/controls/control.' + .'control_name'}}"
    }
    column "query" {
      href =  "${local.hub_path}{{'/queries/' + .'query'}}"
    }
    column "description" {
      wrap = "all"
    }
    column "source_definition" {
      wrap = "all"
    }
  }
}