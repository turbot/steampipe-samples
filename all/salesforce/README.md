# Salesforce dashboards

This mod defines one dashboard that includes:

- `Quick facts`: Using infocards.

- `Contacts`: By lead source and title

- `Leads`: By status and hotness (linked to leads in Salesforce)

- `Events`: Linked to calendars in Salesforce

- `Products`: Just `select * from salesforce_product`

As shown in the demo, it is fast and easy to rewire these widgets.

# Setup

1. Install [Steampipe](https://steampipe.io/downloads)
2. Install/configure [the Salesforce plugin](https://hub.steampipe.io/plugins/turbot/salesforce)
3. `steampipe dashboard`
4. Visit localhost:9194

# Demo

https://user-images.githubusercontent.com/46509/176276927-bd49cc7c-241d-4f8e-90cc-4756985e4b32.mp4



