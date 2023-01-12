dashboard "plugin_versions_inherit_nodes_and_edges_passing_args" {

  tags = {
    service = "v18 examples"
  }

  input "plugin_name" {
    base = input.plugin_name
  }

  graph {
    title = "ldap plugin versions: inherit nodes and edges, passing args"  

    node {
      base = node.plugin_version
      args = [ self.input.plugin_name.value ]
    }

    node {
      base = node.plugin_tag
      args = [ self.input.plugin_name.value ]
    }

    edge {
      base = edge.plugin_to_version
      args = [ self.input.plugin_name.value ]
    }

    edge {
      base = edge.version_to_tag
      args = [ self.input.plugin_name.value ]
    }

  }
}



