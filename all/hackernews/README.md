# Hacker News dashboards

## Setup

- Install [Steampipe](https://steampipe.io/downloads)
- `mkdir ~/csv`
- Install [the CSV plugin](https://hub.steampipe.io/plugins/turbot/csv) (`steampipe plugin install csv`), edit `~/.steampipe/config/csv.spc`, set `paths = [ "~/csv/*.csv" ]`
- Clone this repo and visit `steampipe-samples/all/hackernews`
- Run `./update.sh`
- Run `steampipe dashboard`
- Open localhost:9194

## Dashboard: Home

- `infocards`: A set of cards that count items (All/Ask HN/Show HN), the span of days they cover, max and average scores.

- `users by total score: last 7 days`

- `users by total comments: last 7 days`

- `stories by total comments: last 7 days`

- `ask and show by hour`: Chart of Ask and Show counts over time.

- `company mentions`: A series of donut charts covering different time spans.

- `language mentions`: Same for programming languages.

- `os mentions`: Same for operating systems.

- `cloud mentions`: Same for major clouds.

- `db mentions`: Same for databases.

- `editor mentions`: Same for editors.

## Dashboard: People

The Hacker News username in first column links to the `Submissions` dashboard and selects that user.

A Hacker News username will often match a GitHub username, which in turn may yield a Twitter username. When that happens this table links to one or both accounts. 

## Dashboard: Posts

Top-rated posts, with links to each Hacker News item, to the `Submissions` dashboard for the author, to the URL cited in the post, and to a search on the URL's domain.

## Dashboard: Repos

Hacker News items with GitHub URLs matching company names.

## Dashboard: Search

Finds items whose titles and/or URLs match the search term. It's a regex match, here are some examples.

- `gpt`: Anything about GPT
- `go.+compiler`: Matches "gcassert is a linter for Go compiler decisions"
- `simonwillison`: Matches `simonwillison.net` and `til.simonwillison.net`
- `github.com/microsoft`: Matches Microsoft's GitHub repos
- `github.com.+pytorch`: Matches PyTorch repos
- `nytimes.+/technology`: Matches articles in the NYTimes' technology section

## Dashboard: Sources

This dashboard reports the number of HN items by target domain (e.g. www.nytimes.com), with a drilldown chart showing the timeline of items referring to each domain.

## Dashboard: Submissions

The `by` columns in the `Home` dashboard link here. This dashboard charts a selected user's HN submissions and provides links to each item. 

## Dashboard: Urls

A table of top-scoring URLs, with charts of their domains by occurrences and by max score.

# Notes

This repo uses a GitHub action that fetches new items on an hourly schedule and checks each set of items into the repo as a timestamped CSV file. The `./update.sh` script runs `git pull` to refresh the set of CSV files in the local `./csv` directory, then combines them into a single file (`~/csv/hn.csv`), then runs Steampipe to recreate the table (`hn_items_all`) used by the dashboards. Run `./update.sh` at any time to pull the latest hourly CSV snapshots into the repo, update `hn_items_all`, and view up-to-date dashboards.

You can add to or alter the existing dashboards, create new ones, or just use the Steampipe CLI to query the `hn_items_all` table. See [Writing Dashboards](https://steampipe.io/docs/mods/writing-dashboards#tutorial) for a dashboard tutorial, and [It's Just SQL!](https://steampipe.io/docs/sql/steampipe-sql) for an introduction to useful SQL idioms. 

# Demo

https://user-images.githubusercontent.com/46509/181120985-b4e09ede-e72d-4669-b947-d07b2b2fcad4.mp4


