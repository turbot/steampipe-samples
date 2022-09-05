"""
push hn_items_all and hn_people to steampipe cloud
"""

import os, psycopg2, requests

def connect():
  conn_str = f""" host='localhost' dbname='steampipe' user='steampipe' \
    port='9193' password='{os.environ['STEAMPIPE_LOCAL_PASSWORD']}' """
  conn = psycopg2.connect(conn_str)
  return conn.cursor()

def push(sql):
  url = 'https://cloud.steampipe.io/api/latest/org/acme/workspace/jon/query'
  data = {'sql':sql}
  token = os.environ['STEAMPIPE_CLOUD_TOKEN']
  headers = {"Authorization": "Bearer " + token}
  r = requests.post(url, headers=headers, data=data)
  return r.text

def escape(row):
  _row = []
  for col in row:
    col = col.replace("'", "''")
    col = col.replace('""', '"')
    col = col.replace('"', "''")
    _row.append(col)
  row = str(tuple(_row))
  row = row.replace('"', "'")
  return row

def init_sql(table):
  return ( f'insert into public.{table} values ' )

def push_rows(table, query):
  cur = connect()
  cur.execute(query)
  rows = cur.fetchall()
  i = 0
  sql = init_sql(table)
  values = []
  for row in rows:
    i += 1
    value = escape(row)
    values.append( value )
    if i % 1000 == 0:
      sql += ','.join(values)
      print(i, push(sql))
      sql = init_sql(table)
      values = []
  if i == len(rows) and len(values):
    sql = init_sql(table)
    sql += ','.join(values)
    print(i, push(sql))

push('drop table if exists hn_items_all')
push('create table public.hn_items_all ( id text, title text, "time" text, by text, score text, descendants text, type text, url text )')
push_rows('hn_items_all', 'select id, title, "time", by, score, descendants, type, url from public.hn_items_all order by id desc')
push('grant all for hn_items_all to public')

push('drop table if exists hn_people')
push('create table hn_people (by text, karma text, max_score text, stories text, comments text, github_url text, gh_name text, public_repos text, gh_followers text, twitter_url text)')
push_rows('hn_people', 'select by, karma, max_score, stories, comments, github_url, gh_name, public_repos, gh_followers, twitter_url from public.hn_people')
push('grant all for hn_people to public')

    
