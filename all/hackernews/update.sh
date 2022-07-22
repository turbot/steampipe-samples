echo 'git pull'
git pull 2>&1

echo 'create table hn_items_all'
cp hn_items_all.csv ~/csv >/dev/null 2>&1
steampipe query "drop table if exists hn_items_all" >/dev/null 2>&1
steampipe query "create table public.hn_items_all as select distinct on (id) * from csv.hn_items_all" >/dev/null 2>&1

echo 'create index'
steampipe query "create index idx_hn_items_all_by on public.hn_items_all(by)" >/dev/null 2>&1

echo 'cast types'
steampipe query "update hn_items_all set descendants = 0::text where descendants = '<null>'" >/dev/null 2>&1
steampipe query "update hn_items_all set descendants = 0::text where descendants = '<null>'" >/dev/null 2>&1
steampipe query "update hn_items_all set score = 0::text where score = '<null>'" >/dev/null 2>&1
steampipe query "update hn_items_all set url = '' where url = '<null>'" >/dev/null 2>&1

echo 'create table hn_people'
cp people.csv ~/csv/ >/dev/null 2>&1
steampipe query "drop table if exists hn_people" >/dev/null 2>&1
steampipe query "create table public.hn_people as select * from csv.people" >/dev/null 2>&1

echo 'now run `steampipe dashboard`, then visit http://localhost:9194 and check out the hacker news dashboard!'

 
