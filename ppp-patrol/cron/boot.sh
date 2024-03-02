#!/bin/bash

MY_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
PATROL_PATH=`/usr/bin/dirname ${MY_PATH}`

docker container restart palworld-server_palworld_1

${PATROL_PATH}/broadcast-ip/broadcast-ip.sh
