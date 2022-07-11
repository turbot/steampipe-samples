import re, time

arg_pattern = r'(args = \[ local.companies, )(\d+)(, )(\d+)'

title_pattern = '(company mentions: )(\d+)( to )(\d+)( hours ago)'

max = 60 * 24 * 5

hours_ago = 12

def shift():
  with open('animation.sp', 'r') as f1:
    s = f1.read()
    a_group = re.search(arg_pattern, s).group()
    a_groups = re.search(arg_pattern, s).groups()
    a1 = int(a_groups[1])
    a3 = int(a_groups[3])
    a1 = a1 - 60 * hours_ago
    a3 = a3 - 60 * hours_ago
    if a3 < 0:
      a1 = max
      a3 = a1 - 60 * hours_ago
    a_group2 = f'args = [ local.companies, {a1}, {a3}'
    s = s.replace(a_group, a_group2)

    t_group = re.search(title_pattern, s).group()
    t_group2 = f'company mentions: {int(a1/60)} to {int(a3/60)} hours ago'
    s = s.replace(t_group, t_group2)

  with open('animation.sp', 'w') as f2:
    f2.write(s)

while True:
  shift()
  time.sleep(1)
