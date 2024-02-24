#!/bin/bash -e

MY_PATH=`/usr/bin/dirname ${0}`
PATROL_PATH=`/usr/bin/dirname ${MY_PATH}`

YYYYMMDDHHMMSS=`date +%Y%m%d-%H%M%S`
YYYYMMDD=${YYYYMMDDHHMMSS:0:8}

mkdir -p ${MY_PATH}/log

/usr/bin/bash -e ${MY_PATH}/_stat.sh ${YYYYMMDDHHMMSS} >> ${MY_PATH}/log/${YYYYMMDD}.log 2>&1
