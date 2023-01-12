dashboard "edge_inline_in_graph" {
 
  tags = {
    service = "v18 examples"
  }

  input "plugin_name" {
    base = input.plugin_name
  }    
  
  graph {
    title = "edge inline in graph"

    edge {
      title = "name_to_digest"

      sql = <<-EOQ
        select
            name as from_id,
            digest as to_id
        from
            steampipe_registry_plugin_version
        where
            name = 'turbot/ldap'
      EOQ
    }

    node {
      base = node.plugin_version
      args = [ self.input.plugin_name.value ]
    }

    node {
      base = node.plugin_tag
      args = [ self.input.plugin_name.value ]
    }

    edge {
      base = edge.version_to_tag
      args = [ self.input.plugin_name.value ]
    }

  }

}