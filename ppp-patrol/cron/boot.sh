#!/bin/bash

MY_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
PATROL_PATH=`/usr/bin/dirname ${MY_PATH}`

aws s3 cp \
  s3://luzi82-palworld/config/current/PalWorldSettings.ini \
  /root/palworld-server/data/Config/LinuxServer/
aws s3 cp \
  s3://luzi82-palworld/config/current/WorldOption.sav \
  /root/palworld-server/data/Config/LinuxServer/

docker container restart palworld-server_palworld_1

${PATROL_PATH}/broadcast-ip/broadcast-ip.sh
