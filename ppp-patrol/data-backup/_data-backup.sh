#!/bin/bash -e

MY_PATH=`/usr/bin/dirname ${0}`
PATROL_PATH=`/usr/bin/dirname ${MY_PATH}`

YYYYMMDDHHMMSS=`date +%Y%m%d-%H%M%S`
YYYY=${YYYYMMDDHHMMSS:0:4}
MM=${YYYYMMDDHHMMSS:4:2}

mkdir -p ${MY_PATH}/var

${PATROL_PATH}/venv/bin/python ${PATROL_PATH}/common/timeout_archive_clean.py \
  --folder_path ${MY_PATH}/var

cd /root/palworld-server
tar -czf ${MY_PATH}/var/data.${YYYYMMDDHHMMSS}.tar.gz data
aws s3 cp ${MY_PATH}/var/data.${YYYYMMDDHHMMSS}.tar.gz s3://luzi82-palworld/data-backup/${YYYY}/${MM}/
