edge "plugin_to_version" {
  title = "plugin_to_version"

  sql = <<-EOQ
    select
      name as from_id,
      digest as to_id
    from
      steampipe_registry_plugin_version
    where
      name = $1
  EOQ

  param "plugin_name" {}
}

edge "version_to_tag" {
  title = "version_to_tag"

  sql = <<-EOQ
    select
      digest as from_id,
      concat(digest,':',tag) as to_id
    from
      steampipe_registry_plugin_version,
      jsonb_array_elements(tags) as tag
    where
      name = $1
  EOQ

  param "plugin_name" {}
}

edge "name_to_digest" {
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