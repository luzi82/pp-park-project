# import _config
# print(_config.PALWORLD_PASSWORD)

import re

txt = ''
with open('/root/palworld-server/data/Config/LinuxServer/PalWorldSettings.ini') as fin:
  for line in fin:
    line = line.strip()
    txt += line

m = re.search('ServerPassword="([^?"]*)"',txt)
print(m.group(1))
