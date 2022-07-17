echo 'git pull'

git pull

cat hn_header.txt > hn.csv

echo 'combine csv files'

for file in ./csv/hn_*.csv; do
  tail -n +2 $file >> hn.csv
done

mv hn.csv ~/csv

echo 'drop table if exists hn_items_tmp'
steampipe query "drop table if exists public.hn_items_tmp"

echo 'create table hn_items_tmp'
steampipe query "create table public.hn_items_tmp as select * from csv.hn"

echo 'drop table if exists hn_items_all'
steampipe query "drop table if exists public.hn_items_all"

echo 'create table hn_items_all'
steampipe query "create table public.hn_items_all as select distinct on (id) * from hn_items_tmp"

echo 'create indexes'
steampipe query "create index idx_hn_items_all_by on public.hn_items_all(by)"
#steampipe query "create index idx_hn_items_all_url on public.hn_items_all(url)"
#steampipe query "create index idx_hn_items_all_score on public.hn_items_all(score)"
#steampipe query "create index idx_hn_items_all_descendants on public.hn_items_all(descendants)"

echo 'set null comments to 0'
steampipe query "update hn_items_all set descendants = 0::text where descendants = '<null>'"

echo 'create table hn_scores_and_comments'
steampipe query "drop table if exists hn_scores_and_comments"
steampipe query "create table public.hn_scores_and_comments as select id, score, descendants from hn_items_all where score::int >= 5 "
steampipe query "create index idx_hn_scores_and_comments_id on public.hn_scores_and_comments(id)"

echo 'update hn_items_all from new_sc'
cp new_sc.csv ~/csv/
steampipe query query.update_scores_and_comments

steampipe query "update hn_items_all set descendants = 0::text where descendants = '<null>'"
steampipe query "update hn_items_all set score = 0::text where score = '<null>'"
steampipe query "update hn_items_all set url = '' where url = '<null>'"


echo 'create table hn_people'
cp people.csv ~/csv/
steampipe query "drop table if exists hn_people"
steampipe query "create table public.hn_people as select * from csv.people"


 
