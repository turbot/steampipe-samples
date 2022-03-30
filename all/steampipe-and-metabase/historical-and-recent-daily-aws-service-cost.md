In [Bring live data to Metabase](https://steampipe.io/blog/steampipe-and-metabase) we mentioned a query that uses the [aws_cost_by_service_daily](https://hub.steampipe.io/plugins/turbot/aws/tables/aws_cost_by_service_daily) table to compare historical and recent costs. Here are the elements of that query.

## 1. Make a list of service names 

```
select distinct
  service
from 
  aws_cost_by_service_daily
order by
  service
```

```
                     service
--------------------------------------
 AWS Certificate Manager
 AWS CloudTrail
 AWS Config
 AWS Cost Explorer
```

## 2. Combine the list of services with per-service averages over the full time span

```
with services as (
  select distinct
    service
  from 
    aws_cost_by_service_daily
),
averages as (
  select 
    service,
    avg(blended_cost_amount) as daily_average_cost
  from 
    aws_cost_by_service_daily
  join
    services 
  using 
    (service)
  group by 
    service 
  order by
    service
)
select 
  *
from averages
```

```
                     service                     |   daily_average_cost
-------------------------------------------------+------------------------
 AWS Certificate Manager                         |                   0.75
 AWS CloudTrail                                  |   0.025401098630136978
 AWS Config                                      |  0.0048000000000000004
 AWS Cost Explorer                               |     1.9985000000000004
```

## 3. Combine the list of services with recent per-service costs

```
with services as (
  select distinct
    service
  from aws_cost_by_service_daily
),
recent as (
  select 
    service,
    blended_cost_amount::numeric as recent_cost 
  from 
    aws_cost_by_service_daily
  join
    services s 
  using 
    (service)
  where 
    period_end > now() - interval '2 day'
)
select
  *
from 
  recent
```

```
                  service                  |  recent_cost
-------------------------------------------+---------------
 AWS Key Management Service                |  0.6000000048
 AWS Secrets Manager                       |       0.00713
 Amazon DynamoDB                           |  0.0000156746
 Amazon Macie                              |      0.046032
```

## 4. Now join `averages` and `recent`, and compare them

```
with services as (
  select distinct
    service
  from aws_cost_by_service_daily
),
averages as (
  select 
    service,
    avg(blended_cost_amount) as daily_average_cost
  from 
    aws_cost_by_service_daily a
  join
    services s 
  using 
    (service)
  group by 
    service 
  order by
    service
),
recent as (
  select 
    service,
    blended_cost_amount as recent_cost 
  from 
    aws_cost_by_service_daily
  join
    services
  using (service)
  where 
    period_end > now() - interval '2 day'
),
combined as (
  select
    service,
    daily_average_cost,
    recent_cost
  from 
    averages
  left join 
    recent
  using 
    (service)
  where 
    daily_average_cost > 0
    and recent_cost > 0
 )
 select 
   service,
   daily_average_cost,
   recent_cost,
   round( (recent_cost::numeric / daily_average_cost)::numeric * 100, 2) as recent_pct_of_avg
 from 
   combined
```

```
                  service                  |   daily_average_cost   |  recent_cost  | recent_pct_of_avg
-------------------------------------------+------------------------+---------------+-------------------
 AmazonCloudWatch                          |    0.07302214878684918 |  0.1077393326 |            147.54
 AWS Key Management Service                |    0.13599693594027407 |  0.6000000048 |            441.19
 AWS Secrets Manager                       |   0.005445727272727273 |       0.00713 |            130.93
 Amazon DynamoDB                           |    0.11499504263041092 |   1.56746e-05 |              0.01
 EC2 - Other                               |     2.2539385568106876 |  5.4309044887 |            240.95
 Amazon Elastic File System                | 1.5453731343283595e-08 |      5.76e-08 |            372.73
 Amazon Managed Streaming for Apache Kafka |     13.075897435036525 | 16.7466666672 |            128.07
 Amazon Relational Database Service        |     0.7240060679964416 |  0.4847001384 |             66.95
 Amazon Simple Storage Service             |    0.01884552276767124 |  0.0223423482 |            118.56
 Amazon Elastic Load Balancing             |     0.2330143928602231 |  0.5407457762 |            232.07
 Amazon Macie                              |   0.018254805194805185 |      0.046032 |            252.16
```
