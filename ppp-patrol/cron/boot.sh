#!/bin/bash

MY_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
PATROL_PATH=`/usr/bin/dirname ${MY_PATH}`

MY_IP=`curl http://checkip.amazonaws.com`
PW=`${PATROL_PATH}/venv/bin/python ${PATROL_PATH}/common/pw.py`

${PATROL_PATH}/venv/bin/python ${PATROL_PATH}/common/broadcast.py NOTICE "PP園區首家線上伺服器上線啦♪ IP=${MY_IP}:8211 pw=${PW}"
