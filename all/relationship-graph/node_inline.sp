dashboard "node_plugin_version_inline" {

  tags = {
    service = "v18 examples"
  }

  graph "inline_node" {
    title = "node inline"
    
    node {
      category = category.plugin_version

      sql = <<EOQ
        select
          digest as id,
          left(split_part(digest,':',2),12) as title,
          json_build_object(
            'digest', digest,
            'created', create_time,
            'updated', update_time
          ) as properties
        from
          steampipe_registry_plugin_version
        where
          name = 'turbot/ldap'
      EOQ
    } 
  }

}

