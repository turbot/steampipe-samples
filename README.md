# Steampipe samples

Examples, samples, snippets and scripts to use with Steampipe.

## GitHub external contributor analysis

[This folder](./github-external-contributor-analysis/) has the SQL script we used to produce [A portrait of VSCode's external contributors](https://steampipe.io/blog/vscode-analysis), along with a tool that builds versions of that script for other GitHub repos. 

## Spreadsheet integrity

[This folder](./spreadsheet-integrity) has the ingredients we used to produce [Using SQL to check spreadsheet integrity](https://steampipe.io/blog/spreadsheet-integrity).

## GitHub user activity

[This page](./github_activity/README.md) shows how the [github_search_issue](https://hub.steampipe.io/plugins/turbot/github/tables/github_search_issue) and [github_search_pull_request](https://hub.steampipe.io/plugins/turbot/github/tables/github_search_pull_request) tables enable queries about a user's GitHub activity.

## Querying Gmail

The Google Workspace plugin,  [steampipe-plugin-googleworkspace](https://hub.steampipe.io/plugins/turbot/googleworkspace), includes the [gmail_message](https://hub.steampipe.io/plugins/turbot/googleworkspace/tables/googleworkspace_gmail_message) table. As per the examples there, typical uses of the plugin rely on `query=` in the WHERE clause to leverage Gmail's advanced search syntax and thus limit results to what can be fetched quickly from the API. 

It's also possible, as shown [here](./gmail/README.md), to load an archive of messages into Steampipe and use Postgres capabilities -- extra columns, indexes, convenience functions -- to enable SQL analysis of the archive.
## Steampipe introspection

When launched in a directory that contains mod resources, Steampipe builds introspection tables including `steampipe_query`, `steampipe_benchmark`, and `steampipe_control`. [This page](./introspection/README.md) shows how to iterate over a list of mod names, git-clone of them, query those tables, and accumulate counts of those resources in a CSV file.
