When launched in a directory that contains mod resources, Steampipe builds introspection tables including `steampipe_query`, `steampipe_benchmark`, and `steampipe_control`. This example shows that you can visualize those tables in a dashboard.

The setup:

```
steampipe mod install github.com/turbot/steampipe-mod-aws-thrifty

Installed 1 mod:

local
└── github.com/turbot/steampipe-mod-aws-thrifty@v0.12

steampipe dashboard
[ Wait    ] Loading Workspace
[ Wait    ] Starting Dashboard Server
[ Message ] Workspace loaded
[ Ready   ] Dashboard server started on 9194 and listening on local
[ Message ] Visit http://localhost:9194
[ Message ] Press Ctrl+C to exit
[ Message ] Initialization complete

https://localhost:9194
```

The `source_definition` column of `steampipe_control` has the Postgres type `text`, not `jsonb`, so this example illustrates the use of the Postgres `regexp_matches` function to dig out the query and descriptions from the `source_definition`.

Links back to the hub are accomplished using the [HCL href argument with a jq template](https://steampipe.io/docs/reference/mod-resources/table#jq-templates), in combination with HCL variable interpolation of a [local variable](https://steampipe.io/docs/reference/mod-resources/locals).


https://user-images.githubusercontent.com/46509/164294598-a2cdd7b7-7666-4858-b47e-cd9c87f03c5a.mp4

