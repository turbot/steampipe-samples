connection "hackernews" {
  plugin = "hackernews"

  # Define the maximum number of items to list in the hackernews_item table.
  # Items are listed in reverse from the current maxitem returned by the API.
  # If not set, the default is 5000.
  max_items = 1000
}
