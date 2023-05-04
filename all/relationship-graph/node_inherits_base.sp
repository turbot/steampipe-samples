dashboard "node_inherits_base" {

  tags = {
    service = "v18 examples"
  }

  graph {
    title = "node inherits base"

    node {
      base = node.plugin
    }

  }
}

