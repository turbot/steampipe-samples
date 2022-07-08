# GitHub issue duration

For a specified subset of your repos, this dashboard explores how long issues remain open in each repo.

## Setup

- Install [Steampipe](https://steampipe.io/downloads)
- Install and configure [the GitHub plugin](https://hub.steampipe.io/plugins/turbot/github)
- Clone this repo and visit `steampipe-samples/all/github-issue-duration`
- Edit `mod.sp` and set `repo_pattern` to a regex that matches the repos you want to explore
- Run `steampipe dashboard`
- Open localhost:9194

# Demo

https://user-images.githubusercontent.com/46509/178044297-7083aee2-053e-46c7-a8b8-2a3c1973d02d.mp4

