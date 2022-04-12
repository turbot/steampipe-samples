import csv

with open('avatars.csv', 'r') as csvfile:
  reader = csv.DictReader(csvfile)
  row = next(reader)
  dashboard = f"""
    mod "avatars" {{
    }}

    dashboard "avatars" {{
      title = "committers for {row['repo']}"

  """

with open('avatars.csv', 'r') as csvfile:
  reader = csv.DictReader(csvfile)
  for row in reader:
    dashboard += f"""
      image {{
        title = "{row['alt']} ({row['count']})"
        width=1
        src = "{row['src']}"
        alt = "{row['alt']}"
      }} 

    """
  dashboard += "}"

  print(dashboard)