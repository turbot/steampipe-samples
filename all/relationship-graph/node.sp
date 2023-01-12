node "plugin" {
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
  EOQ
}

node "plugin_version" {
  category = category.plugin_version

  sql = <<-EOQ
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
      name = $1
  EOQ

  param "plugin_name" {}
}

node "plugin_tag" {
  category = category.plugin_tag

  sql = <<-EOQ
    select
      concat(digest,':',tag) as id,
      tag as title
    from
      steampipe_registry_plugin_version,
      jsonb_array_elements(tags) as tag
    where
      name = $1
  EOQ

  param "plugin_name" {}
}