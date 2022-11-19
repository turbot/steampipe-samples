benchmark "repo_semver" {
    title         = "Benchmark: Repo names use semantic versioning"
    children = [
    control.plugin_repos_use_semantic_versioning,
    control.mod_repos_use_monotonic_versioning
    ]
}

control "plugin_repos_use_semantic_versioning" {
  title = "Latest tagged releases of Steampipe plugins use semantic versioning"
  query = query.repos_use_semantic_versioning
  args = [ "turbot/steampipe-plugin", "^v[0-9]+.[0-9]+.[0-9]+" ]
}

control "mod_repos_use_monotonic_versioning" {
  title = "Latest tagged releases of Steampipe mods use monotonic versioning"
  query = query.repos_use_semantic_versioning
  args = [ "turbot/steampipe-mod", "^v[0-9]+.[0-9]" ]
}