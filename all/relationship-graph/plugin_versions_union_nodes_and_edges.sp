dashboard "plugin_versions_tags_union_nodes_and_edges" {

  tags = {
    service = "v18 examples"
  }

  graph {
    title = "plugin versions: union nodes and edges"

    category "plugin" {
      title = "plugin"
      icon  = "extension"
      color = "darkred"
    }

    category "plugin_version" {
      title = "version"
      icon  = "difference"
      color = "darkred"
    }

    category "plugin_tag" {
      title = "tag"
      icon  = "sell"
      color = "black"
    }

    sql = <<EOQ
      -- plugin nodes
      select
        name as id,
        null as from_id,
        null as to_id,
        name as title,
        'plugin' as category,
        jsonb_build_object(
          'name', name,
          'created', create_time,
          'updated', update_time
        ) as properties
      from
        steampipe_registry_plugin
      where
        name = 'turbot/ldap'

      -- plugin version nodes
      union all
      select
        digest as id,
        null as from_id,
        null as to_id,
        left(split_part(digest,':',2),12) as title,
        'plugin_version' as category,
        jsonb_build_object(
          'digest', digest,
          'created', create_time,
          'updated', update_time
        ) as properties
      from
        steampipe_registry_plugin_version
      where
        name = 'turbot/ldap'

      -- plugin tag nodes
      union all
      select
        concat(digest,':',tag) as id,
        null as from_id,
        null as to_id,
        tag as title,
        'plugin_tag' as category,
        null as properties
      from
        steampipe_registry_plugin_version,
        jsonb_array_elements_text(tags) as tag
      where
        name = 'turbot/ldap'

      -- plugin version edges
      union all
      select
        null as id,
        name as from_id,
        digest as to_id,
        'version' as title,
        null as category,
        null as properties
      from
        steampipe_registry_plugin_version
      where
        name = 'turbot/ldap'

      -- plugin tag edges
      union all
      select
        null as id,
        digest as from_id,
        concat(digest,':',tag) as to_id,
        'tag' as title,
        null as category,
        null as properties
      from
        steampipe_registry_plugin_version,
        jsonb_array_elements_text(tags) as tag
      where
        name = 'turbot/ldap'
    EOQ
  }
}