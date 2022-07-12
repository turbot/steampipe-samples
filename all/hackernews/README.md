# Hackernews dashboards

## Setup

- Install [Steampipe](https://steampipe.io/downloads)
- Install [the CSV plugin](https://hub.steampipe.io/plugins/turbot/csv) and configure its `~/.steampipe/config/csv.spc` with a path that includes `~/csv/*.csv` (e.g. `paths = [ "/home/jon/csv/*.csv" ]`
- Clone this repo and visit `steampipe-samples/all/hackernews`
- Run `./update.sh`
- Run `steampipe dashboard`
- Open localhost:9194

## Dashboard: Everything

- `infocards`: A set of cards that count items (All/Ask HN/Show HN), the span of days they cover, max and average scores.

- `users with > 5 posts`: Chart of users with the most posts.

- `stories by hour`: Chart of story counts over time.

- `ask and show by hour`: Chart of Ask and Show counts over time.

- `company mentions`: A series of donut charts covering different time spans.

- `language mentions`: Same for programming languages.

- `os mentions`: Same for operating systems.

- `cloud mentions`: Same for major clouds.

- `database mentions`: Same for databases

- `top-rated stories`: Stories ranked by score.

- `gitHub and twitter info for hn users`: A Hackernews username will often match a GitHub username, and sometimes also a Twitter username. When those matches occur, this table links to HN users' GitHub and Twitter accounts, and reports follower counts for both. The Hackernews username in column 1 of the chart links to the `Submissions` dashboard and selects that user.

## Dashboard: Search

Finds items whose titles and/or URLs match the search term. It's a regex match so, for example, `yandex(.+)gpt` matches the title *Yandex opensources 100B parameter GPT-like model* and `github.com(.+) matches the URL *https://github.com/lucidrains/parti-pytorch*.

## Dashboard: Submissions

The `by` columns in the `Everything` dashboard link here. This dashboard charts a select user's HN submissions and provides links to each item. 

## Dashboard: Sources

This dashboard reports the number of HN items by target domain (e.g. www.nytimes.com), with a drilldown chart showing the timeline of items referring to each domain.

# Notes

This repo uses a GitHub action that fetches new items on an hourly schedule and checks each set of items into the repo as a timestamped CSV file. The `./update.sh` script runs `git pull` to refresh the set of CSV files in the local `./csv` directory, then combines them into a single file (`~/csv/hn.csv`), then runs Steampipe to recreate the table (`hn_items_all`) used by the dashboards. Run `./update.sh` at any time to pull the latest hourly CSV snapshots into the repo, update `hn_items_all`, and view up-to-date dashboards.

You can add to or alter the existing dashboards, create new ones, or just use the Steampipe CLI to query the `hn_items_all` table. See [Writing Dashboards](https://steampipe.io/docs/mods/writing-dashboards#tutorial) for a dashboard tutorial, and [It's Just SQL!](https://steampipe.io/docs/sql/steampipe-sql) for an introduction to useful SQL idioms. 

# Demo


https://user-images.githubusercontent.com/46509/178551249-f138a5dd-c5fc-4a37-a0cc-6610ad3c074f.mp4


