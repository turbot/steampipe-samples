Querying structured files has become another Steampipe superpower. First came [CSV](https://hub.steampipe.io/plugins/csv), then [Terraform](https://hub.steampipe.io/plugins/terraform), and now [Config](https://hub.steampipe.io/plugins/config) which enables queries of YAML/JSON/INI config files. This example shows how to query the [OpenAPI example definitions](https://github.com/OAI/OpenAPI-Specification).

## Install the plugin

```
steampipe plugin install config
```

## Clone the repo

```
cd ~
git clone https://github.com/OAI/OpenAPI-specification
```

## Edit `~/.steampipe/config/config.spc`, recursively enumerate .yaml files in the repo

```
connection "config" {
  plugin = "config"
  yml_paths  = [ "~/OpenAPI-Specification/examples/**/*.yaml" ]
}
```

## Run your queries!

### find titles

```
select
  replace(path, '/home/jon/OpenAPI-Specification/examples/','') as path,
  content -> 'info' -> 'title' as title
from yml_file
```

### find uri paths

```
select
  replace(path, '/home/jon/OpenAPI-Specification/examples/','') as path,
  jsonb_object_keys(content -> 'paths') as uri_path
from yml_file
```

### find components with required elements

```
with schema_keys as (
  select
   replace(path, '/home/jon/OpenAPI-Specification/examples/','') as path,
   jsonb_object_keys(content -> 'components' -> 'schemas') as schema_key
  from yml_file
),
schemas as (
  select
    replace(path, '/home/jon/OpenAPI-Specification/examples/','') as path,
    content -> 'components' -> 'schemas' as schema
   from yml_file
   where content -> 'components' -> 'schemas' is not null
),
required as (
  select
    s.path,
    k.schema_key,
    s.schema -> k.schema_key -> 'required' as required
  from  schemas s join schema_keys k using (path)
)
select * from required where jsonb_typeof(required) = 'array'
```


