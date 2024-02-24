#!/bin/bash

MY_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
PATROL_PATH=`/usr/bin/dirname ${MY_PATH}`

NOW_TS=`date +%s`
NOW_TS_D60=$((${NOW_TS} / 60 ))
NOW_TS_D60_M15=$((${NOW_TS_D60} % 15))

YYYYMMDDHHMMSS=`date +%Y%m%d-%H%M%S`
YYYYMMDD=${YYYYMMDDHHMMSS:0:8}

${PATROL_PATH}/stat/stat.sh

if [ "${NOW_TS_D60_M15}" == "0" ]; then
  ${PATROL_PATH}/backup/backup.sh
fi

${PATROL_PATH}/auto-off/auto-off.sh
