# Steampipe samples

Examples, samples, snippets and scripts to use with Steampipe.

## Table of Contents

- [Joining CSV and API tables](#joining-csv-and-api-tables)
- [GitHub external contributor analysis](#github-external-contributor-analysis)
- [Spreadsheet integrity](#spreadsheet-integrity)
- [GitHub user activity](#github-user-activity)
- [Querying Gmail](#querying-gmail)
- [Steampipe introspection](#steampipe-introspection)
- [Querying OpenAPI definitions](#querying-openapi-definitions)
- [Postgres+Steampipe histograms](#postgressteampipe-histograms)
## Joining CSV and API tables

The scenario: you have a list of service names and IP addresses in a CSV file. You'd like to join that list, on IP address, to AWS resources. [This example](./join-csv-and-api/README.md) shows how.
## GitHub external contributor analysis

[This folder](./github-external-contributor-analysis/) has the SQL script we used to produce [A portrait of VSCode's external contributors](https://steampipe.io/blog/vscode-analysis), along with a tool that builds versions of that script for other GitHub repos. 

## Spreadsheet integrity

[This folder](./spreadsheet-integrity) has the ingredients we used to produce [Using SQL to check spreadsheet integrity](https://steampipe.io/blog/spreadsheet-integrity).

## GitHub user activity

[This page](./github_activity/README.md) shows how the [github_search_issue](https://hub.steampipe.io/plugins/turbot/github/tables/github_search_issue) and [github_search_pull_request](https://hub.steampipe.io/plugins/turbot/github/tables/github_search_pull_request) tables enable queries about a user's GitHub activity.

## Querying Gmail

The Google Workspace plugin,  [steampipe-plugin-googleworkspace](https://hub.steampipe.io/plugins/turbot/googleworkspace), includes the [gmail_message](https://hub.steampipe.io/plugins/turbot/googleworkspace/tables/googleworkspace_gmail_message) table. As per the examples there, typical uses of the plugin rely on `query=` in the WHERE clause to leverage Gmail's advanced search syntax and thus limit results to what can be fetched quickly from the API. 

[This example](./gmail/README.md) shows how to load an archive of messages into Steampipe and use Postgres capabilities -- extra columns, indexes, convenience functions -- to enable SQL analysis of the archive.
## Steampipe introspection

When launched in a directory that contains mod resources, Steampipe builds introspection tables including `steampipe_query`, `steampipe_benchmark`, and `steampipe_control`. [This page](./introspection/README.md) shows how to iterate over a list of mod names, git-clone one of them, query those tables, and accumulate counts of those resources in a CSV file.

## Querying OpenAPI definitions

Querying structured files has become another Steampipe superpower. First [CSV](https://hub.steampipe.io/plugins/csv), then [Terraform](https://hub.steampipe.io/plugins/terraform), and now [Config](https://hub.steampipe.io/plugins/config) which enables queries of YAML/JSON/INI config files. [This example](./config-yaml/README.md) shows how to query the OpenAPI example definitions at [github.com/OAI/OpenAPI-Specification](https://github.com/OAI/OpenAPI-Specification).

## Postgres+Steampipe histograms

Postgres provides a couple of functions that you can  use in combination to [make histograms](https://tapoueh.org/blog/2014/02/postgresql-aggregates-and-histograms/). In [this example](./histogram/README.md) we adapt that approach to Steampipe.


