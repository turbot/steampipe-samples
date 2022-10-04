# Add or remove a topic to/from a a set of GitHub repos matching a pattern

For Hacktoberfest we needed to add the topic `hacktoberfest` to 134 repos whose names match the pattern `turbot/steampipe-(plugin|mod)`. This tool does that, using a Steampipe query to get the list of repo names, and the GitHub API to adjust their topics.

It illustrates two ways to use Steampipe programmatically.

1. `queryPostgresForRepos()` makes a database connection and issues a query against that connection. In this example that's a connection to a local instance of Steampipe, but it could as easily be to a workspace in Steampipe Cloud.

2. `querySpcForRepos()` makes a REST call to the [Steamipe Cloud query API](https://steampipe.io/docs/cloud/develop/query-api).

