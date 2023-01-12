dashboard "edge_reusable_with_base_passing_args" {

  tags = {
    service = "v18 examples"
  }

  input "plugin_name" {
    base = input.plugin_name
  }    

  graph {
    title = "edge reusable with base passing args"

    edge {
      base = edge.plugin_to_version
      args = [ self.input.plugin_name.value ]
    }

    node {
      base = node.plugin
    }

    node {
      base = node.plugin_version
      args = [ self.input.plugin_name.value ]
    }

    edge {
      base = edge.plugin_to_version
      args = [ self.input.plugin_name.value ]      
    }


  }
}

