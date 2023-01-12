query "plugin_input" {
  sql = <<-EOQ
    select
      name as value,
      name as label
    from
      steampipe_registry_plugin
    order by
      name
  EOQ
}