import re, time

arg_pattern = r'(args = )([^d]+)(\d+)(, )(\d+)( ] // companies)'


title_pattern = r'(company mentions: )(\d+)( to )(\d+)( hours ago)'

max = 60 * 24 * 5

hours_ago = 12

def shift():
  with open('animation.sp', 'r') as f1:
    s = f1.read()
    a_group = re.search(arg_pattern, s).group()
    a_groups = re.search(arg_pattern, s).groups()
    a0 = a_groups[0]
    a1 = a_groups[1]
    a2 = int(a_groups[2])
    a3 = a_groups[3]
    a4 = int(a_groups[4])
    a5 = a_groups[5]
    a2 = a2 - 60 * hours_ago
    a4 = a2 - 60 * hours_ago
    if a4 < 0:
      a2 = max
      a4 = a2 - 60 * hours_ago
    a_group2 = f'{a0}{a1}{a2}{a3}{a4}{a5}'
    s = s.replace(a_group, a_group2)

    t_group = re.search(title_pattern, s).group()
    t_groups = re.search(title_pattern, s).groups()
    t0 = t_groups[0]
    t2 = t_groups[2]
    t4 = t_groups[4]
    t_group2 = f'{t0}{int(a2/60)}{t2}{int(a4/60)}{t4}'
    s = s.replace(t_group, t_group2)

  with open('animation.sp', 'w') as f2:
    f2.write(s)

while True:
  shift()
  time.sleep(1)
