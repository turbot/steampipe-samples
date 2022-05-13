You've [installed Steampipe](https://steampipe.io/downloads) on your MacOS, Linux, or WSL2 machine. Now you'd like to run one of the [AWS Compliance](https://hub.steampipe.io/mods/turbot/aws_compliance/controls/benchmark.audit_manager_control_tower) benchmarks. 

This quickstart script will:

1. Check if the required AWS plugin is installed, and if not, install it.

2. Check if the AWS Compliance mod is installed, and if not, install it.

3. Present a menu of 11 benchmarks you can run.

```
./quickstart.sh
```

Note: The script doesn't handle authentication. If you're running in [AWS CloudShell](https://dev.to/aws-builders/instantly-query-aws-with-sql-in-cloudshell-hd0) you're good to go. Otherwise please see the [plugin documentation](https://hub.steampipe.io/plugins/turbot/aws) for details on the various kinds of credentials and modes of authentication.
