git pull

cat hn_header.txt > hn.csv

for file in ./csv/hn_*.csv; do
  tail -n +2 $file >> hn.csv
done

mv hn.csv ~/csv

steampipe query "drop table public.hn_items_all"

steampipe query "create table public.hn_items_all as select distinct on (id) * from csv.hn"
