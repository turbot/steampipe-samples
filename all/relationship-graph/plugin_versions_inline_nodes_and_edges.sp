dashboard "plugin_versions_tags_inline_nodes_and_edges" {

  tags = {
    service = "v18 examples"
  }

  graph {
    title = "plugin versions: inline nodes"

    node {
      category = category.plugin

      sql = <<EOQ
        select
          name as id,
          name as title,
          jsonb_build_object(
            'name', name,
            'created', create_time,
            'updated', update_time
          ) as properties
        from
          steampipe_registry_plugin
       where
          name = 'turbot/ldap'
      EOQ
    }

    node {
      category = category.plugin_version

      sql = <<EOQ
        select
          digest as id,
          left(split_part(digest,':',2),12) as title,
          jsonb_build_object(
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

    node {
      category = category.plugin_tag

      sql = <<EOQ
        select
          concat(digest,':',tag) as id,
          tag as title
        from
          steampipe_registry_plugin_version,
          jsonb_array_elements(tags) as tag
       where
          name = 'turbot/ldap'
      EOQ
    }

    edge {
      title = "version"

      sql = <<EOQ
        select
          name as from_id,
          digest as to_id
        from
          steampipe_registry_plugin_version
        where
          name = 'turbot/ldap'
      EOQ
    }

    edge {
      title = "tag"

      sql = <<EOQ
        select
          digest as from_id,
          concat(digest,':',tag) as to_id
        from
          steampipe_registry_plugin_version,
          jsonb_array_elements(tags) as tag
       where
          name = 'turbot/ldap'
      EOQ
    }

  }
}

