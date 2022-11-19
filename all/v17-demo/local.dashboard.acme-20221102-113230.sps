{
  "schema_version": "20220929",
  "panels": {
    "aws_tags.control.cloudtrail_trail_prohibited": {
      "name": "aws_tags.control.cloudtrail_trail_prohibited",
      "title": "CloudTrail trails should not have prohibited tags",
      "description": "Check if CloudTrail trails have any prohibited tags.",
      "panel_type": "control",
      "properties": {
        "sql": "    with analysis as (\n      select\n        arn,\n        array_agg(k) as prohibited_tags\n      from\n        aws_cloudtrail_trail,\n        jsonb_object_keys(tags) as k,\n        unnest($1::text[]) as prohibited_key\n      where\n        k = prohibited_key\n      group by\n        arn\n    )\n    select\n      r.arn as resource,\n      case\n        when a.prohibited_tags \u003c\u003e array[]::text[] then 'alarm'\n        else 'ok'\n      end as status,\n      case\n        when a.prohibited_tags \u003c\u003e array[]::text[] then r.title || ' has prohibited tags: ' || array_to_string(a.prohibited_tags, ', ') || '.'\n        else r.title || ' has no prohibited tags.'\n      end as reason,\n      r.region, r.account_id\n    from\n      aws_cloudtrail_trail as r\n    full outer join\n      analysis as a on a.arn = r.arn\n"
      },
      "summary": {
        "alarm": 0,
        "ok": 17,
        "info": 0,
        "skip": 0,
        "error": 0
      },
      "status": "complete",
      "data": {
        "columns": [
          {
            "name": "reason",
            "data_type": "TEXT",
            "ScanType": null
          },
          {
            "name": "resource",
            "data_type": "TEXT",
            "ScanType": null
          },
          {
            "name": "status",
            "data_type": "TEXT",
            "ScanType": null
          },
          {
            "name": "region",
            "data_type": "TEXT",
            "ScanType": null
          },
          {
            "name": "account_id",
            "data_type": "TEXT",
            "ScanType": null
          }
        ],
        "rows": [
          {
            "account_id": "605491513981",
            "reason": "management-events has no prohibited tags.",
            "region": "us-west-1",
            "resource": "arn:aws:cloudtrail:us-east-1:605491513981:trail/management-events",
            "status": "ok"
          },
          {
            "account_id": "605491513981",
            "reason": "management-events has no prohibited tags.",
            "region": "us-west-2",
            "resource": "arn:aws:cloudtrail:us-east-1:605491513981:trail/management-events",
            "status": "ok"
          },
          {
            "account_id": "605491513981",
            "reason": "management-events has no prohibited tags.",
            "region": "us-east-1",
            "resource": "arn:aws:cloudtrail:us-east-1:605491513981:trail/management-events",
            "status": "ok"
          },
          {
            "account_id": "605491513981",
            "reason": "management-events has no prohibited tags.",
            "region": "us-east-2",
            "resource": "arn:aws:cloudtrail:us-east-1:605491513981:trail/management-events",
            "status": "ok"
          },
          {
            "account_id": "605491513981",
            "reason": "management-events has no prohibited tags.",
            "region": "ca-central-1",
            "resource": "arn:aws:cloudtrail:us-east-1:605491513981:trail/management-events",
            "status": "ok"
          },
          {
            "account_id": "605491513981",
            "reason": "management-events has no prohibited tags.",
            "region": "ap-northeast-1",
            "resource": "arn:aws:cloudtrail:us-east-1:605491513981:trail/management-events",
            "status": "ok"
          },
          {
            "account_id": "605491513981",
            "reason": "management-events has no prohibited tags.",
            "region": "ap-northeast-3",
            "resource": "arn:aws:cloudtrail:us-east-1:605491513981:trail/management-events",
            "status": "ok"
          },
          {
            "account_id": "605491513981",
            "reason": "management-events has no prohibited tags.",
            "region": "eu-west-2",
            "resource": "arn:aws:cloudtrail:us-east-1:605491513981:trail/management-events",
            "status": "ok"
          },
          {
            "account_id": "605491513981",
            "reason": "management-events has no prohibited tags.",
            "region": "eu-west-3",
            "resource": "arn:aws:cloudtrail:us-east-1:605491513981:trail/management-events",
            "status": "ok"
          },
          {
            "account_id": "605491513981",
            "reason": "management-events has no prohibited tags.",
            "region": "ap-southeast-2",
            "resource": "arn:aws:cloudtrail:us-east-1:605491513981:trail/management-events",
            "status": "ok"
          },
          {
            "account_id": "605491513981",
            "reason": "management-events has no prohibited tags.",
            "region": "eu-central-1",
            "resource": "arn:aws:cloudtrail:us-east-1:605491513981:trail/management-events",
            "status": "ok"
          },
          {
            "account_id": "605491513981",
            "reason": "management-events has no prohibited tags.",
            "region": "ap-northeast-2",
            "resource": "arn:aws:cloudtrail:us-east-1:605491513981:trail/management-events",
            "status": "ok"
          },
          {
            "account_id": "605491513981",
            "reason": "management-events has no prohibited tags.",
            "region": "eu-west-1",
            "resource": "arn:aws:cloudtrail:us-east-1:605491513981:trail/management-events",
            "status": "ok"
          },
          {
            "account_id": "605491513981",
            "reason": "management-events has no prohibited tags.",
            "region": "eu-north-1",
            "resource": "arn:aws:cloudtrail:us-east-1:605491513981:trail/management-events",
            "status": "ok"
          },
          {
            "account_id": "605491513981",
            "reason": "management-events has no prohibited tags.",
            "region": "ap-southeast-1",
            "resource": "arn:aws:cloudtrail:us-east-1:605491513981:trail/management-events",
            "status": "ok"
          },
          {
            "account_id": "605491513981",
            "reason": "management-events has no prohibited tags.",
            "region": "sa-east-1",
            "resource": "arn:aws:cloudtrail:us-east-1:605491513981:trail/management-events",
            "status": "ok"
          },
          {
            "account_id": "605491513981",
            "reason": "management-events has no prohibited tags.",
            "region": "ap-south-1",
            "resource": "arn:aws:cloudtrail:us-east-1:605491513981:trail/management-events",
            "status": "ok"
          }
        ]
      }
    },
    "aws_tags.control.cloudwatch_log_group_prohibited": {
      "name": "aws_tags.control.cloudwatch_log_group_prohibited",
      "title": "CloudWatch log groups should not have prohibited tags",
      "description": "Check if CloudWatch log groups have any prohibited tags.",
      "panel_type": "control",
      "properties": {
        "sql": "    with analysis as (\n      select\n        arn,\n        array_agg(k) as prohibited_tags\n      from\n        aws_cloudwatch_log_group,\n        jsonb_object_keys(tags) as k,\n        unnest($1::text[]) as prohibited_key\n      where\n        k = prohibited_key\n      group by\n        arn\n    )\n    select\n      r.arn as resource,\n      case\n        when a.prohibited_tags \u003c\u003e array[]::text[] then 'alarm'\n        else 'ok'\n      end as status,\n      case\n        when a.prohibited_tags \u003c\u003e array[]::text[] then r.title || ' has prohibited tags: ' || array_to_string(a.prohibited_tags, ', ') || '.'\n        else r.title || ' has no prohibited tags.'\n      end as reason,\n      r.region, r.account_id\n    from\n      aws_cloudwatch_log_group as r\n    full outer join\n      analysis as a on a.arn = r.arn\n"
      },
      "summary": {
        "alarm": 0,
        "ok": 3,
        "info": 0,
        "skip": 0,
        "error": 0
      },
      "status": "complete",
      "data": {
        "columns": [
          {
            "name": "reason",
            "data_type": "TEXT",
            "ScanType": null
          },
          {
            "name": "resource",
            "data_type": "TEXT",
            "ScanType": null
          },
          {
            "name": "status",
            "data_type": "TEXT",
            "ScanType": null
          },
          {
            "name": "region",
            "data_type": "TEXT",
            "ScanType": null
          },
          {
            "name": "account_id",
            "data_type": "TEXT",
            "ScanType": null
          }
        ],
        "rows": [
          {
            "account_id": "605491513981",
            "reason": "jon_cloudwatch_log_group has no prohibited tags.",
            "region": "us-west-1",
            "resource": "arn:aws:logs:us-west-1:605491513981:log-group:jon_cloudwatch_log_group:*",
            "status": "ok"
          },
          {
            "account_id": "605491513981",
            "reason": "log-group-01 has no prohibited tags.",
            "region": "us-west-1",
            "resource": "arn:aws:logs:us-west-1:605491513981:log-group:log-group-01:*",
            "status": "ok"
          },
          {
            "account_id": "605491513981",
            "reason": "/ecs/first-run-task-definition has no prohibited tags.",
            "region": "us-west-1",
            "resource": "arn:aws:logs:us-west-1:605491513981:log-group:/ecs/first-run-task-definition:*",
            "status": "ok"
          }
        ]
      }
    },
    "control.mod_repos_use_monotonic_versioning": {
      "name": "control.mod_repos_use_monotonic_versioning",
      "title": "Latest tagged releases of Steampipe mods use monotonic versioning",
      "panel_type": "control",
      "properties": {
        "query": {
          "name": "repos_use_semantic_versioning",
          "sql": "    with repo_full_names as (\n      select \n        full_name,\n        html_url\n      from\n        github_my_repository\n      where\n        full_name ~ $1\n      ),\n      repo_tags as (\n      select distinct on (r.full_name, t.name)\n        r.full_name,\n        t.name as tag_name,\n        r.html_url || '@' || t.name as url_with_tag,\n        t.commit_sha\n      from        \n        github_tag t\n      join\n        repo_full_names r\n      on\n        r.full_name = t.repository_full_name\n        and r.full_name ~ $1\n      ),\n      dated_repo_tag_shas as (\n        select\n          c.committer_date,\n          c.sha\n      from\n        github_commit c\n      where \n        c.sha in (select commit_sha from repo_tags)\n        and c.repository_full_name in (select full_name from repo_tags)\n      ),\n      dated_releases as (\n        select \n          full_name,\n          tag_name,\n          url_with_tag,\n          committer_date\n        from\n          repo_tags r \n        join\n          dated_repo_tag_shas d\n        on\n          r.commit_sha = d.sha\n      )\n      select distinct on (full_name) \n        url_with_tag as resource,\n          case\n            when tag_name ~ ( $2 || '$') then 'ok'\n            when tag_name ~ $2 then 'info'\n            else 'alarm'\n            end as status,\n          url_with_tag as reason,\n          tag_name,\n          committer_date\n      from\n          dated_releases d\n      order by full_name, committer_date desc\n",
          "params": [
            {
              "name": "repo_pattern",
              "description": null,
              "default": null
            },
            {
              "name": "semver_pattern",
              "description": null,
              "default": null
            }
          ]
        }
      },
      "summary": {
        "alarm": 0,
        "ok": 11,
        "info": 2,
        "skip": 0,
        "error": 0
      },
      "status": "complete",
      "data": {
        "columns": [
          {
            "name": "reason",
            "data_type": "TEXT",
            "ScanType": null
          },
          {
            "name": "resource",
            "data_type": "TEXT",
            "ScanType": null
          },
          {
            "name": "status",
            "data_type": "TEXT",
            "ScanType": null
          },
          {
            "name": "tag_name",
            "data_type": "TEXT",
            "ScanType": null
          },
          {
            "name": "committer_date",
            "data_type": "TIMESTAMPTZ",
            "ScanType": null
          }
        ],
        "rows": [
          {
            "committer_date": "2022-08-18T08:54:45-07:00",
            "reason": "https://github.com/turbot/steampipe-mod-gcp-compliance@v0.11",
            "resource": "https://github.com/turbot/steampipe-mod-gcp-compliance@v0.11",
            "status": "info",
            "tag_name": "v0.11"
          },
          {
            "committer_date": "2022-05-09T14:55:46-07:00",
            "reason": "https://github.com/turbot/steampipe-mod-gcp-thrifty@v0.10",
            "resource": "https://github.com/turbot/steampipe-mod-gcp-thrifty@v0.10",
            "status": "info",
            "tag_name": "v0.10"
          },
          {
            "committer_date": "2022-05-09T15:26:08-07:00",
            "reason": "https://github.com/turbot/steampipe-mod-alicloud-compliance@v0.5",
            "resource": "https://github.com/turbot/steampipe-mod-alicloud-compliance@v0.5",
            "status": "ok",
            "tag_name": "v0.5"
          },
          {
            "committer_date": "2022-05-09T15:20:56-07:00",
            "reason": "https://github.com/turbot/steampipe-mod-alicloud-thrifty@v0.6",
            "resource": "https://github.com/turbot/steampipe-mod-alicloud-thrifty@v0.6",
            "status": "ok",
            "tag_name": "v0.6"
          },
          {
            "committer_date": "2022-09-12T06:29:57-07:00",
            "reason": "https://github.com/turbot/steampipe-mod-aws-tags@v0.6",
            "resource": "https://github.com/turbot/steampipe-mod-aws-tags@v0.6",
            "status": "ok",
            "tag_name": "v0.6"
          },
          {
            "committer_date": "2022-05-09T14:30:25-07:00",
            "reason": "https://github.com/turbot/steampipe-mod-digitalocean-insights@v0.2",
            "resource": "https://github.com/turbot/steampipe-mod-digitalocean-insights@v0.2",
            "status": "ok",
            "tag_name": "v0.2"
          },
          {
            "committer_date": "2022-09-09T06:54:40-07:00",
            "reason": "https://github.com/turbot/steampipe-mod-gcp-labels@v0.6",
            "resource": "https://github.com/turbot/steampipe-mod-gcp-labels@v0.6",
            "status": "ok",
            "tag_name": "v0.6"
          },
          {
            "committer_date": "2022-08-16T13:45:47-07:00",
            "reason": "https://github.com/turbot/steampipe-mod-hackernews-insights@v0.2",
            "resource": "https://github.com/turbot/steampipe-mod-hackernews-insights@v0.2",
            "status": "ok",
            "tag_name": "v0.2"
          },
          {
            "committer_date": "2022-05-17T09:42:28-07:00",
            "reason": "https://github.com/turbot/steampipe-mod-ibm-compliance@v0.6",
            "resource": "https://github.com/turbot/steampipe-mod-ibm-compliance@v0.6",
            "status": "ok",
            "tag_name": "v0.6"
          },
          {
            "committer_date": "2022-10-14T09:04:29-07:00",
            "reason": "https://github.com/turbot/steampipe-mod-microsoft365-compliance@v0.2",
            "resource": "https://github.com/turbot/steampipe-mod-microsoft365-compliance@v0.2",
            "status": "ok",
            "tag_name": "v0.2"
          },
          {
            "committer_date": "2022-05-09T15:10:27-07:00",
            "reason": "https://github.com/turbot/steampipe-mod-oci-insights@v0.4",
            "resource": "https://github.com/turbot/steampipe-mod-oci-insights@v0.4",
            "status": "ok",
            "tag_name": "v0.4"
          },
          {
            "committer_date": "2022-10-07T10:13:21-07:00",
            "reason": "https://github.com/turbot/steampipe-mod-tailscale-compliance@v0.1",
            "resource": "https://github.com/turbot/steampipe-mod-tailscale-compliance@v0.1",
            "status": "ok",
            "tag_name": "v0.1"
          },
          {
            "committer_date": "2022-06-09T07:54:10-07:00",
            "reason": "https://github.com/turbot/steampipe-mod-terraform-aws-compliance@v0.9",
            "resource": "https://github.com/turbot/steampipe-mod-terraform-aws-compliance@v0.9",
            "status": "ok",
            "tag_name": "v0.9"
          }
        ]
      }
    },
    "control.plugin_repos_use_semantic_versioning": {
      "name": "control.plugin_repos_use_semantic_versioning",
      "title": "Latest tagged releases of Steampipe plugins use semantic versioning",
      "panel_type": "control",
      "properties": {
        "query": {
          "name": "repos_use_semantic_versioning",
          "sql": "    with repo_full_names as (\n      select \n        full_name,\n        html_url\n      from\n        github_my_repository\n      where\n        full_name ~ $1\n      ),\n      repo_tags as (\n      select distinct on (r.full_name, t.name)\n        r.full_name,\n        t.name as tag_name,\n        r.html_url || '@' || t.name as url_with_tag,\n        t.commit_sha\n      from        \n        github_tag t\n      join\n        repo_full_names r\n      on\n        r.full_name = t.repository_full_name\n        and r.full_name ~ $1\n      ),\n      dated_repo_tag_shas as (\n        select\n          c.committer_date,\n          c.sha\n      from\n        github_commit c\n      where \n        c.sha in (select commit_sha from repo_tags)\n        and c.repository_full_name in (select full_name from repo_tags)\n      ),\n      dated_releases as (\n        select \n          full_name,\n          tag_name,\n          url_with_tag,\n          committer_date\n        from\n          repo_tags r \n        join\n          dated_repo_tag_shas d\n        on\n          r.commit_sha = d.sha\n      )\n      select distinct on (full_name) \n        url_with_tag as resource,\n          case\n            when tag_name ~ ( $2 || '$') then 'ok'\n            when tag_name ~ $2 then 'info'\n            else 'alarm'\n            end as status,\n          url_with_tag as reason,\n          tag_name,\n          committer_date\n      from\n          dated_releases d\n      order by full_name, committer_date desc\n",
          "params": [
            {
              "name": "repo_pattern",
              "description": null,
              "default": null
            },
            {
              "name": "semver_pattern",
              "description": null,
              "default": null
            }
          ]
        }
      },
      "summary": {
        "alarm": 0,
        "ok": 59,
        "info": 0,
        "skip": 0,
        "error": 0
      },
      "status": "complete",
      "data": {
        "columns": [
          {
            "name": "reason",
            "data_type": "TEXT",
            "ScanType": null
          },
          {
            "name": "resource",
            "data_type": "TEXT",
            "ScanType": null
          },
          {
            "name": "status",
            "data_type": "TEXT",
            "ScanType": null
          },
          {
            "name": "tag_name",
            "data_type": "TEXT",
            "ScanType": null
          },
          {
            "name": "committer_date",
            "data_type": "TIMESTAMPTZ",
            "ScanType": null
          }
        ],
        "rows": [
          {
            "committer_date": "2022-09-28T01:20:11-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-abuseipdb@v0.3.0",
            "resource": "https://github.com/turbot/steampipe-plugin-abuseipdb@v0.3.0",
            "status": "ok",
            "tag_name": "v0.3.0"
          },
          {
            "committer_date": "2022-09-28T01:46:53-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-algolia@v0.2.0",
            "resource": "https://github.com/turbot/steampipe-plugin-algolia@v0.2.0",
            "status": "ok",
            "tag_name": "v0.2.0"
          },
          {
            "committer_date": "2022-09-06T07:01:46-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-alicloud@v0.10.0",
            "resource": "https://github.com/turbot/steampipe-plugin-alicloud@v0.10.0",
            "status": "ok",
            "tag_name": "v0.10.0"
          },
          {
            "committer_date": "2022-09-27T22:37:26-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-awscfn@v0.2.0",
            "resource": "https://github.com/turbot/steampipe-plugin-awscfn@v0.2.0",
            "status": "ok",
            "tag_name": "v0.2.0"
          },
          {
            "committer_date": "2022-09-29T00:28:48-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-azure@v0.33.0",
            "resource": "https://github.com/turbot/steampipe-plugin-azure@v0.33.0",
            "status": "ok",
            "tag_name": "v0.33.0"
          },
          {
            "committer_date": "2022-09-28T01:54:17-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-buildkite@v0.1.0",
            "resource": "https://github.com/turbot/steampipe-plugin-buildkite@v0.1.0",
            "status": "ok",
            "tag_name": "v0.1.0"
          },
          {
            "committer_date": "2022-06-17T06:04:27-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-chaos@v0.1.0",
            "resource": "https://github.com/turbot/steampipe-plugin-chaos@v0.1.0",
            "status": "ok",
            "tag_name": "v0.1.0"
          },
          {
            "committer_date": "2022-09-27T23:50:06-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-cloudflare@v0.5.0",
            "resource": "https://github.com/turbot/steampipe-plugin-cloudflare@v0.5.0",
            "status": "ok",
            "tag_name": "v0.5.0"
          },
          {
            "committer_date": "2022-09-27T22:06:34-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-code@v0.3.0",
            "resource": "https://github.com/turbot/steampipe-plugin-code@v0.3.0",
            "status": "ok",
            "tag_name": "v0.3.0"
          },
          {
            "committer_date": "2022-09-26T09:53:24-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-config@v0.2.0",
            "resource": "https://github.com/turbot/steampipe-plugin-config@v0.2.0",
            "status": "ok",
            "tag_name": "v0.2.0"
          },
          {
            "committer_date": "2022-09-27T07:15:04-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-crowdstrike@v0.1.0",
            "resource": "https://github.com/turbot/steampipe-plugin-crowdstrike@v0.1.0",
            "status": "ok",
            "tag_name": "v0.1.0"
          },
          {
            "committer_date": "2022-09-28T05:25:07-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-crtsh@v0.1.0",
            "resource": "https://github.com/turbot/steampipe-plugin-crtsh@v0.1.0",
            "status": "ok",
            "tag_name": "v0.1.0"
          },
          {
            "committer_date": "2022-09-28T06:25:50-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-datadog@v0.2.0",
            "resource": "https://github.com/turbot/steampipe-plugin-datadog@v0.2.0",
            "status": "ok",
            "tag_name": "v0.2.0"
          },
          {
            "committer_date": "2022-09-27T07:03:49-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-digitalocean@v0.10.0",
            "resource": "https://github.com/turbot/steampipe-plugin-digitalocean@v0.10.0",
            "status": "ok",
            "tag_name": "v0.10.0"
          },
          {
            "committer_date": "2022-09-26T02:02:01-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-equinix@v0.3.0",
            "resource": "https://github.com/turbot/steampipe-plugin-equinix@v0.3.0",
            "status": "ok",
            "tag_name": "v0.3.0"
          },
          {
            "committer_date": "2022-09-27T23:59:25-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-finance@v0.3.0",
            "resource": "https://github.com/turbot/steampipe-plugin-finance@v0.3.0",
            "status": "ok",
            "tag_name": "v0.3.0"
          },
          {
            "committer_date": "2022-09-29T08:36:16-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-googleworkspace@v0.5.0",
            "resource": "https://github.com/turbot/steampipe-plugin-googleworkspace@v0.5.0",
            "status": "ok",
            "tag_name": "v0.5.0"
          },
          {
            "committer_date": "2022-10-20T18:09:13-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-hcloud@v0.4.0",
            "resource": "https://github.com/turbot/steampipe-plugin-hcloud@v0.4.0",
            "status": "ok",
            "tag_name": "v0.4.0"
          },
          {
            "committer_date": "2022-09-28T05:56:56-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-hibp@v0.1.0",
            "resource": "https://github.com/turbot/steampipe-plugin-hibp@v0.1.0",
            "status": "ok",
            "tag_name": "v0.1.0"
          },
          {
            "committer_date": "2022-09-28T00:53:08-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-ibm@v0.3.0",
            "resource": "https://github.com/turbot/steampipe-plugin-ibm@v0.3.0",
            "status": "ok",
            "tag_name": "v0.3.0"
          },
          {
            "committer_date": "2022-11-01T06:18:16-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-ipinfo@v0.0.1",
            "resource": "https://github.com/turbot/steampipe-plugin-ipinfo@v0.0.1",
            "status": "ok",
            "tag_name": "v0.0.1"
          },
          {
            "committer_date": "2022-09-27T01:17:27-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-ipstack@v0.7.0",
            "resource": "https://github.com/turbot/steampipe-plugin-ipstack@v0.7.0",
            "status": "ok",
            "tag_name": "v0.7.0"
          },
          {
            "committer_date": "2022-10-13T12:24:58-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-jira@v0.6.1",
            "resource": "https://github.com/turbot/steampipe-plugin-jira@v0.6.1",
            "status": "ok",
            "tag_name": "v0.6.1"
          },
          {
            "committer_date": "2022-10-19T07:39:42-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-kubernetes@v0.12.0",
            "resource": "https://github.com/turbot/steampipe-plugin-kubernetes@v0.12.0",
            "status": "ok",
            "tag_name": "v0.12.0"
          },
          {
            "committer_date": "2022-09-26T03:08:18-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-ldap@v0.2.0",
            "resource": "https://github.com/turbot/steampipe-plugin-ldap@v0.2.0",
            "status": "ok",
            "tag_name": "v0.2.0"
          },
          {
            "committer_date": "2022-09-27T00:53:14-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-mongodbatlas@v0.1.1",
            "resource": "https://github.com/turbot/steampipe-plugin-mongodbatlas@v0.1.1",
            "status": "ok",
            "tag_name": "v0.1.1"
          },
          {
            "committer_date": "2022-09-28T07:37:26-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-net@v0.8.0",
            "resource": "https://github.com/turbot/steampipe-plugin-net@v0.8.0",
            "status": "ok",
            "tag_name": "v0.8.0"
          },
          {
            "committer_date": "2022-09-19T20:16:05-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-oci@v0.17.1",
            "resource": "https://github.com/turbot/steampipe-plugin-oci@v0.17.1",
            "status": "ok",
            "tag_name": "v0.17.1"
          },
          {
            "committer_date": "2022-09-27T00:06:34-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-okta@v0.8.0",
            "resource": "https://github.com/turbot/steampipe-plugin-okta@v0.8.0",
            "status": "ok",
            "tag_name": "v0.8.0"
          },
          {
            "committer_date": "2022-09-28T06:08:59-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-pagerduty@v0.2.1",
            "resource": "https://github.com/turbot/steampipe-plugin-pagerduty@v0.2.1",
            "status": "ok",
            "tag_name": "v0.2.1"
          },
          {
            "committer_date": "2022-09-27T23:10:23-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-panos@v0.1.0",
            "resource": "https://github.com/turbot/steampipe-plugin-panos@v0.1.0",
            "status": "ok",
            "tag_name": "v0.1.0"
          },
          {
            "committer_date": "2022-04-27T11:04:49-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-planetscale@v0.1.0",
            "resource": "https://github.com/turbot/steampipe-plugin-planetscale@v0.1.0",
            "status": "ok",
            "tag_name": "v0.1.0"
          },
          {
            "committer_date": "2022-05-25T04:31:38-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-prometheus@v0.1.0",
            "resource": "https://github.com/turbot/steampipe-plugin-prometheus@v0.1.0",
            "status": "ok",
            "tag_name": "v0.1.0"
          },
          {
            "committer_date": "2022-09-16T21:17:10-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-reddit@v0.1.0",
            "resource": "https://github.com/turbot/steampipe-plugin-reddit@v0.1.0",
            "status": "ok",
            "tag_name": "v0.1.0"
          },
          {
            "committer_date": "2022-09-26T23:54:56-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-rss@v0.3.0",
            "resource": "https://github.com/turbot/steampipe-plugin-rss@v0.3.0",
            "status": "ok",
            "tag_name": "v0.3.0"
          },
          {
            "committer_date": "2022-06-24T14:02:23-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-salesforce@v0.2.0",
            "resource": "https://github.com/turbot/steampipe-plugin-salesforce@v0.2.0",
            "status": "ok",
            "tag_name": "v0.2.0"
          },
          {
            "committer_date": "2022-09-26T22:22:27-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-scaleway@v0.3.0",
            "resource": "https://github.com/turbot/steampipe-plugin-scaleway@v0.3.0",
            "status": "ok",
            "tag_name": "v0.3.0"
          },
          {
            "committer_date": "2022-09-08T01:19:18-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-sdk@v4.1.7",
            "resource": "https://github.com/turbot/steampipe-plugin-sdk@v4.1.7",
            "status": "ok",
            "tag_name": "v4.1.7"
          },
          {
            "committer_date": "2022-09-26T02:55:40-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-shodan@v0.4.0",
            "resource": "https://github.com/turbot/steampipe-plugin-shodan@v0.4.0",
            "status": "ok",
            "tag_name": "v0.4.0"
          },
          {
            "committer_date": "2022-10-26T15:17:41-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-slack@v0.9.1",
            "resource": "https://github.com/turbot/steampipe-plugin-slack@v0.9.1",
            "status": "ok",
            "tag_name": "v0.9.1"
          },
          {
            "committer_date": "2022-10-11T06:04:35-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-splunk@v0.3.0",
            "resource": "https://github.com/turbot/steampipe-plugin-splunk@v0.3.0",
            "status": "ok",
            "tag_name": "v0.3.0"
          },
          {
            "committer_date": "2022-09-26T21:14:06-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-steampipe@v0.6.0",
            "resource": "https://github.com/turbot/steampipe-plugin-steampipe@v0.6.0",
            "status": "ok",
            "tag_name": "v0.6.0"
          },
          {
            "committer_date": "2022-09-26T20:55:11-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-steampipecloud@v0.5.0",
            "resource": "https://github.com/turbot/steampipe-plugin-steampipecloud@v0.5.0",
            "status": "ok",
            "tag_name": "v0.5.0"
          },
          {
            "committer_date": "2022-10-03T13:02:52-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-stripe@v0.3.1",
            "resource": "https://github.com/turbot/steampipe-plugin-stripe@v0.3.1",
            "status": "ok",
            "tag_name": "v0.3.1"
          },
          {
            "committer_date": "2022-10-06T06:00:08-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-tailscale@v0.1.0",
            "resource": "https://github.com/turbot/steampipe-plugin-tailscale@v0.1.0",
            "status": "ok",
            "tag_name": "v0.1.0"
          },
          {
            "committer_date": "2022-09-08T22:44:11-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-terraform@v0.2.0",
            "resource": "https://github.com/turbot/steampipe-plugin-terraform@v0.2.0",
            "status": "ok",
            "tag_name": "v0.2.0"
          },
          {
            "committer_date": "2022-09-28T00:59:09-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-tfe@v0.3.1",
            "resource": "https://github.com/turbot/steampipe-plugin-tfe@v0.3.1",
            "status": "ok",
            "tag_name": "v0.3.1"
          },
          {
            "committer_date": "2022-09-08T13:45:55-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-trivy@v0.1.0",
            "resource": "https://github.com/turbot/steampipe-plugin-trivy@v0.1.0",
            "status": "ok",
            "tag_name": "v0.1.0"
          },
          {
            "committer_date": "2022-09-08T13:20:41-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-turbot@v0.9.0",
            "resource": "https://github.com/turbot/steampipe-plugin-turbot@v0.9.0",
            "status": "ok",
            "tag_name": "v0.9.0"
          },
          {
            "committer_date": "2022-10-05T10:29:15-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-twilio@v0.3.1",
            "resource": "https://github.com/turbot/steampipe-plugin-twilio@v0.3.1",
            "status": "ok",
            "tag_name": "v0.3.1"
          },
          {
            "committer_date": "2022-09-08T13:28:31-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-twitter@v0.2.0",
            "resource": "https://github.com/turbot/steampipe-plugin-twitter@v0.2.0",
            "status": "ok",
            "tag_name": "v0.2.0"
          },
          {
            "committer_date": "2022-09-08T13:08:57-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-updown@v0.3.0",
            "resource": "https://github.com/turbot/steampipe-plugin-updown@v0.3.0",
            "status": "ok",
            "tag_name": "v0.3.0"
          },
          {
            "committer_date": "2022-09-16T12:50:10-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-uptimerobot@v0.0.1",
            "resource": "https://github.com/turbot/steampipe-plugin-uptimerobot@v0.0.1",
            "status": "ok",
            "tag_name": "v0.0.1"
          },
          {
            "committer_date": "2022-09-08T13:05:03-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-urlscan@v0.3.0",
            "resource": "https://github.com/turbot/steampipe-plugin-urlscan@v0.3.0",
            "status": "ok",
            "tag_name": "v0.3.0"
          },
          {
            "committer_date": "2022-09-08T12:50:02-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-vercel@v0.1.0",
            "resource": "https://github.com/turbot/steampipe-plugin-vercel@v0.1.0",
            "status": "ok",
            "tag_name": "v0.1.0"
          },
          {
            "committer_date": "2022-09-08T12:32:59-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-virustotal@v0.3.0",
            "resource": "https://github.com/turbot/steampipe-plugin-virustotal@v0.3.0",
            "status": "ok",
            "tag_name": "v0.3.0"
          },
          {
            "committer_date": "2022-09-08T12:23:22-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-whois@v0.6.0",
            "resource": "https://github.com/turbot/steampipe-plugin-whois@v0.6.0",
            "status": "ok",
            "tag_name": "v0.6.0"
          },
          {
            "committer_date": "2022-09-08T12:14:45-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-zendesk@v0.5.0",
            "resource": "https://github.com/turbot/steampipe-plugin-zendesk@v0.5.0",
            "status": "ok",
            "tag_name": "v0.5.0"
          },
          {
            "committer_date": "2022-09-08T11:54:03-07:00",
            "reason": "https://github.com/turbot/steampipe-plugin-zoom@v0.5.0",
            "resource": "https://github.com/turbot/steampipe-plugin-zoom@v0.5.0",
            "status": "ok",
            "tag_name": "v0.5.0"
          }
        ]
      }
    },
    "local.benchmark.aws_tags": {
      "name": "local.benchmark.aws_tags",
      "title": "Benchmark: No prohibited AWS tags",
      "panel_type": "benchmark",
      "dashboard": "dashboard.acme",
      "source_definition": "    benchmark \"aws_tags\" {\n      title         = \"Benchmark: No prohibited AWS tags\"\n      children = [\n        aws_tags.control.cloudtrail_trail_prohibited,\n        aws_tags.control.cloudwatch_log_group_prohibited,\n      ]\n    }",
      "summary": {
        "status": {
          "alarm": 0,
          "ok": 20,
          "info": 0,
          "skip": 0,
          "error": 0
        }
      }
    },
    "local.benchmark.repo_semver": {
      "name": "local.benchmark.repo_semver",
      "title": "Benchmark: Repo names use semantic versioning",
      "panel_type": "benchmark",
      "dashboard": "dashboard.acme",
      "source_definition": "    benchmark \"repo_semver\" {\n      title         = \"Benchmark: Repo names use semantic versioning\"\n      children = [\n        control.plugin_repos_use_semantic_versioning,\n        control.mod_repos_use_monotonic_versioning\n      ]\n    }",
      "summary": {
        "status": {
          "alarm": 0,
          "ok": 70,
          "info": 2,
          "skip": 0,
          "error": 0
        }
      }
    },
    "local.chart.aws_regions": {
      "name": "local.chart.aws_regions",
      "title": "Regions for Cloudwatch log groups and CloudTrail trails",
      "display_type": "donut",
      "sql": "        with cloudwatch_log_group_regions as (\n          select \n            region,\n            count(*)\n          from\n            aws_cloudwatch_log_group\n          group by \n            region\n        ),\n        cloudtrail_trail_regions as (\n          select\n            region,\n            count(*)\n          from\n            aws_cloudtrail_trail\n          group by\n            region\n        )\n        select * from  cloudwatch_log_group_regions\n        union \n        select * from  cloudtrail_trail_regions\n        order by count desc, region\n",
      "data": {
        "columns": [
          {
            "name": "region",
            "data_type": "TEXT",
            "ScanType": {}
          },
          {
            "name": "count",
            "data_type": "INT8",
            "ScanType": {}
          }
        ],
        "rows": [
          {
            "count": 3,
            "region": "us-west-1"
          },
          {
            "count": 1,
            "region": "ap-northeast-1"
          },
          {
            "count": 1,
            "region": "ap-northeast-2"
          },
          {
            "count": 1,
            "region": "ap-northeast-3"
          },
          {
            "count": 1,
            "region": "ap-south-1"
          },
          {
            "count": 1,
            "region": "ap-southeast-1"
          },
          {
            "count": 1,
            "region": "ap-southeast-2"
          },
          {
            "count": 1,
            "region": "ca-central-1"
          },
          {
            "count": 1,
            "region": "eu-central-1"
          },
          {
            "count": 1,
            "region": "eu-north-1"
          },
          {
            "count": 1,
            "region": "eu-west-1"
          },
          {
            "count": 1,
            "region": "eu-west-2"
          },
          {
            "count": 1,
            "region": "eu-west-3"
          },
          {
            "count": 1,
            "region": "sa-east-1"
          },
          {
            "count": 1,
            "region": "us-east-1"
          },
          {
            "count": 1,
            "region": "us-east-2"
          },
          {
            "count": 1,
            "region": "us-west-1"
          },
          {
            "count": 1,
            "region": "us-west-2"
          }
        ]
      },
      "properties": {},
      "panel_type": "chart",
      "status": "complete",
      "dashboard": "dashboard.acme",
      "source_definition": "    chart \"aws_regions\" {\n      type = \"donut\"\n      title = \"Regions for Cloudwatch log groups and CloudTrail trails\"\n      sql = \u003c\u003cEOQ\n        with cloudwatch_log_group_regions as (\n          select \n            region,\n            count(*)\n          from\n            aws_cloudwatch_log_group\n          group by \n            region\n        ),\n        cloudtrail_trail_regions as (\n          select\n            region,\n            count(*)\n          from\n            aws_cloudtrail_trail\n          group by\n            region\n        )\n        select * from  cloudwatch_log_group_regions\n        union \n        select * from  cloudtrail_trail_regions\n        order by count desc, region\n      EOQ\n    }"
    },
    "local.container.dashboard_acme_anonymous_container_0": {
      "name": "local.container.dashboard_acme_anonymous_container_0",
      "width": 6,
      "panel_type": "container",
      "status": "complete",
      "dashboard": "dashboard.acme",
      "source_definition": "  container {\n\n    width = 6\n\n    benchmark \"aws_tags\" {\n      title         = \"Benchmark: No prohibited AWS tags\"\n      children = [\n        aws_tags.control.cloudtrail_trail_prohibited,\n        aws_tags.control.cloudwatch_log_group_prohibited,\n      ]\n    }\n\n    chart \"aws_regions\" {\n      type = \"donut\"\n      title = \"Regions for Cloudwatch log groups and CloudTrail trails\"\n      sql = \u003c\u003cEOQ\n        with cloudwatch_log_group_regions as (\n          select \n            region,\n            count(*)\n          from\n            aws_cloudwatch_log_group\n          group by \n            region\n        ),\n        cloudtrail_trail_regions as (\n          select\n            region,\n            count(*)\n          from\n            aws_cloudtrail_trail\n          group by\n            region\n        )\n        select * from  cloudwatch_log_group_regions\n        union \n        select * from  cloudtrail_trail_regions\n        order by count desc, region\n      EOQ\n    }\n\n  }"
    },
    "local.container.dashboard_acme_anonymous_container_1": {
      "name": "local.container.dashboard_acme_anonymous_container_1",
      "width": 6,
      "panel_type": "container",
      "status": "complete",
      "dashboard": "dashboard.acme",
      "source_definition": "  container {\n\n    width = 6\n\n    benchmark \"repo_semver\" {\n      title         = \"Benchmark: Repo names use semantic versioning\"\n      children = [\n        control.plugin_repos_use_semantic_versioning,\n        control.mod_repos_use_monotonic_versioning\n      ]\n    }\n\n    table {\n      title = \"Plugins and mods updated recently\"\n      sql = \u003c\u003cEOQ\n\n        select\n          html_url as Repo,\n          stargazers_count as Stars,\n          to_char(pushed_at, 'YYYY-MM-DD') as pushed_at\n        from\n          github_search_repository\n        where\n          query = 'steampipe-plugin in:name org:turbot'\n\n        union \n\n        select\n          html_url as Repo,\n          stargazers_count as Stars,\n          to_char(pushed_at, 'YYYY-MM-DD') as pushed_at\n        from\n          github_search_repository\n        where\n          query = 'steampipe-mod in:name org:turbot'\n\n        order by\n          pushed_at desc\n        limit 10\n      EOQ\n      column \"Repo\" {\n        wrap = \"all\"\n      }\n\n    }  \n\n  }"
    },
    "local.dashboard.acme": {
      "name": "local.dashboard.acme",
      "tags": {
        "service": "Acme"
      },
      "panel_type": "dashboard",
      "status": "complete",
      "dashboard": "dashboard.acme",
      "source_definition": "dashboard \"acme\" {\n\n  tags = {\n      service = \"Acme\"\n    }\n\n  container {\n\n    width = 6\n\n    benchmark \"aws_tags\" {\n      title         = \"Benchmark: No prohibited AWS tags\"\n      children = [\n        aws_tags.control.cloudtrail_trail_prohibited,\n        aws_tags.control.cloudwatch_log_group_prohibited,\n      ]\n    }\n\n    chart \"aws_regions\" {\n      type = \"donut\"\n      title = \"Regions for Cloudwatch log groups and CloudTrail trails\"\n      sql = \u003c\u003cEOQ\n        with cloudwatch_log_group_regions as (\n          select \n            region,\n            count(*)\n          from\n            aws_cloudwatch_log_group\n          group by \n            region\n        ),\n        cloudtrail_trail_regions as (\n          select\n            region,\n            count(*)\n          from\n            aws_cloudtrail_trail\n          group by\n            region\n        )\n        select * from  cloudwatch_log_group_regions\n        union \n        select * from  cloudtrail_trail_regions\n        order by count desc, region\n      EOQ\n    }\n\n  }\n\n  container {\n\n    width = 6\n\n    benchmark \"repo_semver\" {\n      title         = \"Benchmark: Repo names use semantic versioning\"\n      children = [\n        control.plugin_repos_use_semantic_versioning,\n        control.mod_repos_use_monotonic_versioning\n      ]\n    }\n\n    table {\n      title = \"Plugins and mods updated recently\"\n      sql = \u003c\u003cEOQ\n\n        select\n          html_url as Repo,\n          stargazers_count as Stars,\n          to_char(pushed_at, 'YYYY-MM-DD') as pushed_at\n        from\n          github_search_repository\n        where\n          query = 'steampipe-plugin in:name org:turbot'\n\n        union \n\n        select\n          html_url as Repo,\n          stargazers_count as Stars,\n          to_char(pushed_at, 'YYYY-MM-DD') as pushed_at\n        from\n          github_search_repository\n        where\n          query = 'steampipe-mod in:name org:turbot'\n\n        order by\n          pushed_at desc\n        limit 10\n      EOQ\n      column \"Repo\" {\n        wrap = \"all\"\n      }\n\n    }  \n\n  }\n \n}"
    },
    "local.table.container_dashboard_acme_anonymous_container_1_anonymous_table_0": {
      "name": "local.table.container_dashboard_acme_anonymous_container_1_anonymous_table_0",
      "title": "Plugins and mods updated recently",
      "sql": "\n        select\n          html_url as Repo,\n          stargazers_count as Stars,\n          to_char(pushed_at, 'YYYY-MM-DD') as pushed_at\n        from\n          github_search_repository\n        where\n          query = 'steampipe-plugin in:name org:turbot'\n\n        union \n\n        select\n          html_url as Repo,\n          stargazers_count as Stars,\n          to_char(pushed_at, 'YYYY-MM-DD') as pushed_at\n        from\n          github_search_repository\n        where\n          query = 'steampipe-mod in:name org:turbot'\n\n        order by\n          pushed_at desc\n        limit 10\n",
      "data": {
        "columns": [
          {
            "name": "repo",
            "data_type": "TEXT",
            "ScanType": {}
          },
          {
            "name": "stars",
            "data_type": "INT8",
            "ScanType": {}
          },
          {
            "name": "pushed_at",
            "data_type": "TEXT",
            "ScanType": {}
          }
        ],
        "rows": [
          {
            "pushed_at": "2022-11-02",
            "repo": "https://github.com/turbot/steampipe-plugin-gcp",
            "stars": 24
          },
          {
            "pushed_at": "2022-11-02",
            "repo": "https://github.com/turbot/steampipe-mod-gcp-insights",
            "stars": 4
          },
          {
            "pushed_at": "2022-11-02",
            "repo": "https://github.com/turbot/steampipe-plugin-azure",
            "stars": 22
          },
          {
            "pushed_at": "2022-11-02",
            "repo": "https://github.com/turbot/steampipe-plugin-azuread",
            "stars": 6
          },
          {
            "pushed_at": "2022-11-02",
            "repo": "https://github.com/turbot/steampipe-mod-gcp-compliance",
            "stars": 22
          },
          {
            "pushed_at": "2022-11-02",
            "repo": "https://github.com/turbot/steampipe-mod-aws-tags",
            "stars": 5
          },
          {
            "pushed_at": "2022-11-02",
            "repo": "https://github.com/turbot/steampipe-mod-azure-insights",
            "stars": 5
          },
          {
            "pushed_at": "2022-11-02",
            "repo": "https://github.com/turbot/steampipe-plugin-aws",
            "stars": 107
          },
          {
            "pushed_at": "2022-11-02",
            "repo": "https://github.com/turbot/steampipe-mod-kubernetes-compliance",
            "stars": 19
          },
          {
            "pushed_at": "2022-11-02",
            "repo": "https://github.com/turbot/steampipe-plugin-ipinfo",
            "stars": 1
          }
        ]
      },
      "properties": {
        "columns": {
          "Repo": {
            "name": "Repo",
            "wrap": "all"
          }
        }
      },
      "panel_type": "table",
      "status": "complete",
      "dashboard": "dashboard.acme",
      "source_definition": "    table {\n      title = \"Plugins and mods updated recently\"\n      sql = \u003c\u003cEOQ\n\n        select\n          html_url as Repo,\n          stargazers_count as Stars,\n          to_char(pushed_at, 'YYYY-MM-DD') as pushed_at\n        from\n          github_search_repository\n        where\n          query = 'steampipe-plugin in:name org:turbot'\n\n        union \n\n        select\n          html_url as Repo,\n          stargazers_count as Stars,\n          to_char(pushed_at, 'YYYY-MM-DD') as pushed_at\n        from\n          github_search_repository\n        where\n          query = 'steampipe-mod in:name org:turbot'\n\n        order by\n          pushed_at desc\n        limit 10\n      EOQ\n      column \"Repo\" {\n        wrap = \"all\"\n      }\n\n    }  "
    }
  },
  "inputs": {},
  "variables": {},
  "search_path": [
    "public",
    "abuseipdb",
    "airtable",
    "algolia",
    "aws_1",
    "aws_all",
    "awscfn",
    "azure",
    "azuread",
    "chaos",
    "code",
    "config",
    "crtsh",
    "csv",
    "digitalocean",
    "gcp",
    "github",
    "googleworkspace",
    "hackernews",
    "hello",
    "hibp",
    "html",
    "hypothesis",
    "imap",
    "ipstack",
    "ldap",
    "microsoft365",
    "net",
    "reddit",
    "rss",
    "samplesheet",
    "shodan",
    "slack",
    "steampipe",
    "steampipecloud",
    "tailscale",
    "terraform",
    "trivy",
    "twitter",
    "vercel",
    "xkcd",
    "z_070715377127",
    "internal"
  ],
  "start_time": "2022-11-02T11:31:37.193130175-07:00",
  "end_time": "2022-11-02T11:32:30.065513783-07:00",
  "layout": {
    "name": "local.dashboard.acme",
    "children": [
      {
        "name": "local.container.dashboard_acme_anonymous_container_0",
        "children": [
          {
            "name": "local.benchmark.aws_tags",
            "children": [
              {
                "name": "aws_tags.control.cloudtrail_trail_prohibited",
                "panel_type": "control"
              },
              {
                "name": "aws_tags.control.cloudwatch_log_group_prohibited",
                "panel_type": "control"
              }
            ],
            "panel_type": "benchmark"
          },
          {
            "name": "local.chart.aws_regions",
            "panel_type": "chart"
          }
        ],
        "panel_type": "container"
      },
      {
        "name": "local.container.dashboard_acme_anonymous_container_1",
        "children": [
          {
            "name": "local.benchmark.repo_semver",
            "children": [
              {
                "name": "control.plugin_repos_use_semantic_versioning",
                "panel_type": "control"
              },
              {
                "name": "control.mod_repos_use_monotonic_versioning",
                "panel_type": "control"
              }
            ],
            "panel_type": "benchmark"
          },
          {
            "name": "local.table.container_dashboard_acme_anonymous_container_1_anonymous_table_0",
            "panel_type": "table"
          }
        ],
        "panel_type": "container"
      }
    ],
    "panel_type": "dashboard"
  }
}
