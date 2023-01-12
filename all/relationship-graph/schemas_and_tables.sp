dashboard "schemas_and_tables" {

  tags = {
    service = "v18 examples"
  }

  graph {
    title = "Schemas & Tables"

    node {
      category = category.catalog

      sql = <<-EOQ
        select
          distinct on (catalog_name)
          concat('catalog:',catalog_name) as id,
          catalog_name as title
        from
          information_schema.schemata
       where
          schema_name = 'net'
      EOQ
    }

    node {
      category = category.schema
      sql      = <<-EOQ
        select
          concat('schema:',schema_name) as id,
          schema_name as title,
          json_build_object(
            'catalog', catalog_name,
            'schema', schema_name,
            'owner', schema_owner
          ) as properties
        from
          information_schema.schemata
        where
          schema_name = 'net'
      EOQ
    }

    node {
      category = category.table
      sql      = <<-EOQ
          select
            concat('table:',table_name) as id,
            table_name as title,
            json_build_object(
              'catalog', table_catalog,
              'schema', table_schema,
              'type', table_type
            ) as properties
          from
            information_schema.tables
          where
            table_schema = 'net'
        EOQ
    }

    edge {
      sql = <<-EOQ
          select
            concat('catalog:',catalog_name) as from_id,
            concat('schema:',schema_name) as to_id
          from
            information_schema.schemata
        EOQ
    }

    edge {
      sql = <<-EOQ
          select
            concat('schema:',table_schema) as from_id,
            concat('table:',table_name) as to_id
          from
            information_schema.tables
        EOQ
    }
  }

}

category "catalog" {
  title = "catalog"
  icon  = "book"
  color = "orange"
}

category "schema" {
  title = "schema"
  icon  = "schema"
  color = "blue"
}


category "table" {
  title = "table"
  icon  = "table"
  color = "green"
}
