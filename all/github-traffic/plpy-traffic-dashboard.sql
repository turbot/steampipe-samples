create or replace procedure traffic() as $$
  import re
  sql = """
    select 
      full_name
    from
      github_search_repository
    where
      query = 'steampipe in:name -org:turbotio -org:turbothq '
    and
      full_name ~ 'turbot/steampipe-(plugin|mod)'
    """
  rows = plpy.execute(sql)

  totals = {}
  daily_maxes = {}

  for row in rows:
    sql = f"""
      select
        sum(uniques),
        max(uniques)
      from
        github_traffic_view_daily
      where
        repository_full_name = '{row['full_name']}'
      having
        sum(uniques) > 20
    """
    r = plpy.execute(sql)
    if len(r) > 0:
      totals[row['full_name']] = r[0]['sum']
      daily_maxes[row['full_name']] = r[0]['max']

  sorted_totals = {k: v for k, v in sorted(totals.items(), key=lambda item: item[1], reverse=True)}

  sorted_plugin_names = [k for k in sorted_totals if 'steampipe-plugin' in k]
  sorted_mod_names = [k for k in sorted_totals if 'steampipe-mod' in k]

  plugin_daily_max = max([daily_maxes[k] for k in daily_maxes.keys() if 'steampipe-plugin' in k])
  mod_daily_max = max([daily_maxes[k] for k in daily_maxes.keys() if 'steampipe-mod' in k])  

  def chart(full_name, max):
    name = re.sub('steampipe-(plugin|mod)-', '', full_name)
    chart = f"""
      chart {{
        width = 2
        title = "{name}"
        axes {{
          y {{
              max = {max}
            }}
          }}
        sql = <<EOT
          select
            to_char(timestamp, 'MM-DD'),
            uniques
          from
            github_traffic_view_daily
          where
            repository_full_name = '{full_name}'
          order by
            timestamp;    
        EOT
      }}
    """
    return(chart)

  plugin_charts = ''
  for plugin in sorted_plugin_names:
    plugin_charts += chart(plugin, plugin_daily_max)
  plpy.notice(plugin_charts)

  mod_charts = ''
  for mod in sorted_mod_names:
    mod_charts += chart(mod, mod_daily_max)

  dashboard = f"""
    mod "github-traffic" {{
    }}
    
    dashboard "traffic" {{

    container {{
      title = "plugins"
      {plugin_charts}
    }}

    container {{
      title = "mods"
      {mod_charts}
    }}

  }}
  """
  with open('/home/jon/steampipe-samples/all/github-traffic/mod.sp', 'w') as f:
    f.write(dashboard)
  
$$ language plpython3u;
