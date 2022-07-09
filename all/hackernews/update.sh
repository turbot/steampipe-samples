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
steampipe query "create index idx_hn_items_all_url on public.hn_items_all(url)"
steampipe query "create index idx_hn_items_all_score on public.hn_items_all(score)"
steampipe query "create index idx_hn_items_all_descendants on public.hn_items_all(descendants)"

echo 'set null comments to 0'
steampipe query "update hn_items_all set descendants = 0::text where descendants = '<null>'"

echo 'drop table if exists hn_scores_and_comments'
steampipe query "drop table if exists hn_scores_and_comments"

echo 'create table hn_scores_and_comments'
steampipe query "create table public.hn_scores_and_comments as ( select id::bigint, score, descendants as comments from hn_items_all where score::int > 10 order by time desc )"

echo 'update hn_items_all with new scores and comments'
steampipe query "with new_scores_and_comments as ( select *, (select score::text as new_score from hackernews_item i where i.id = sc.id::bigint),  (select descendants::text as new_comments from hackernews_item i where i.id = sc.id::bigint) from hn_scores_and_comments sc ) update hn_items_all a set score = n.new_score::text, descendants = n.new_comments::text from new_scores_and_comments n where a.id = n.id::text"



