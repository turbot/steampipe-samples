# Comparing methods of SQL reuse in Steampipe dashboards

For simple scenarios, local variables and HCL's replace function work nicely. For more complex scenarios it's possible but unwieldy to use multi-level HCL replace. A Postgres function can be a cleaner solution.

To run the example dashboards:

```
steampipe dashboard
https://localhost:9194
```

See also this [annotated explanation](https://jonudell.info/steampipe/sql-reuse-methods.html) of the techniques.
