dashboard "node_inherits_base_passing_args" {
  
  tags = {
    service = "v18 examples"
  }

  input "plugin_name" {
    base = input.plugin_name
  }  

  graph {
    title = "node inherits base passing args"

    node {
      base = node.plugin_with_arg
      args = [ self.input.plugin_name.value ]
    }
  }

}

node "plugin_with_arg" {
  category = category.plugin

  sql = <<-EOQ
    select
      name as id,
      name as title,
      json_build_object(
        'name', name,
        'created', create_time,
        'updated', update_time
      ) as properties
    from
      steampipe_registry_plugin
    where
      name = $1
  EOQ

  param "plugin_name" {}
}