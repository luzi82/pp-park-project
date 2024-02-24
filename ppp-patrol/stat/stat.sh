#!/bin/bash

MY_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
PATROL_PATH=`/usr/bin/dirname ${MY_PATH}`

YYYYMMDDHHMMSS=`date +%Y%m%d-%H%M%S`
YYYYMMDD=${YYYYMMDDHHMMSS:0:8}

mkdir -p ${MY_PATH}/log

/usr/bin/bash -e ${MY_PATH}/_stat.sh ${YYYYMMDDHHMMSS} >> ${MY_PATH}/log/${YYYYMMDD}.log 2>&1
if [ $? -ne 0 ]; then
  ${PATROL_PATH}/venv/bin/python ${PATROL_PATH}/common/broadcast.py VERBOSE "${0} failed, YYYYMMDDHHMMSS=${YYYYMMDDHHMMSS}"
  exit 1
fi
