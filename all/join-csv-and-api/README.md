# Joining CSV and API tables

The scenario: you have a list of service names and IP addresses in a CSV file. You'd like to join that list, on IP address, to AWS resources.

The file `~/csv/ips.csv` contains this data.

```
service,ip_addr
service1,54.176.63.151
service2,222.236.38.99
service3,41.65.221.12
service4,83.151.87.112
service5,85.188.10.179
```

The CSV plugin is installed, and the `~/.steampipe/config/csv.spc` contains this `paths` directive.

```
connection "csv" {
  plugin = "csv"

  paths = [ "~/csv/*.csv" ]
}
```

This query selects all records in the CSV file.

```
select * from csv.ips

+----------+---------------+
| service  | ip_addr       |
+----------+---------------+
| service1 | 54.176.63.151 |
| service2 | 222.236.38.99 |
| service3 | 41.65.221.12  |
| service4 | 83.151.87.112 |
| service5 | 85.188.10.179 |
+----------+---------------+
```

Here's a query for EC2 endpoints.

```
select private_ip_address, public_ip_address from aws_ec2_instance

+--------------------+-------------------+
| private_ip_address | public_ip_address |
+--------------------+-------------------+
| 172.31.31.137      | 54.176.63.151     |
| 172.31.29.210      | <null>            |
| 10.11.66.164       | <null>            |
| 10.10.10.41        | 18.205.6.164      |
+--------------------+-------------------+
```

And finally, here's a query that joins on IP address and reports EC2 details.


```
select 
  c.service,
  c.ip_addr,
  a.instance_id,
  a.instance_state
from csv.ips c 
join aws_ec2_instance a 
on c.ip_addr = host(a.public_ip_address)
```

```
+----------+---------------+---------------------+----------------+
| service  | ip_addr       | instance_id         | instance_state |
+----------+---------------+---------------------+----------------+
| service1 | 54.176.63.151 | i-06d8571f170181287 | running        |
+----------+---------------+---------------------+----------------+
```

Per the Postgres doc on [network address functions and operators](https://www.postgresql.org/docs/12/functions-net.html), we use the `host` function to convert `a.public_ip_address` from its native type, `inet`, to type `text` so it can join with `c.ip_addr`.