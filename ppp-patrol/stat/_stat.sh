#!/bin/bash -e

export COLUMNS=999
YYYYMMDDHHMMSS=${1}

MY_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
PATROL_PATH=`/usr/bin/dirname ${MY_PATH}`

echo ====START====
echo ${YYYYMMDDHHMMSS}

TMP_DF_OUTPUT=/tmp/df__SCLEWVZSUFSWQKVFQPWWIUTECMTIMDQD__
echo ==DF-START==
df > ${TMP_DF_OUTPUT}
cat ${TMP_DF_OUTPUT}
ROOT_USAGE_PERCENT=`cat ${TMP_DF_OUTPUT} | grep "/dev/root" | awk '{print $5}' | sed 's/%//g'`
if [ ${ROOT_USAGE_PERCENT} -gt 80 ]; then
  ${PATROL_PATH}/venv/bin/python ${PATROL_PATH}/common/broadcast.py VERBOSE "root usage ${ROOT_USAGE_PERCENT}%"
fi
echo ==DF-END==

echo ==ARCHIVE-CLEAN-START==
${PATROL_PATH}/venv/bin/python ${PATROL_PATH}/common/timeout_archive_clean.py \
  --folder_path ${MY_PATH}/log \
  --s3_path stat-log
echo ==ARCHIVE-CLEAN-END==

echo ==TOP-START==
/usr/bin/top -b -n 1 | /usr/bin/grep "PalServer-Linux"
echo ==TOP-END==

echo ==FREE-START==
/usr/bin/free
echo ==FREE-END==

TMP_NETSTAT_OUTPUT=/tmp/netstat__XCPHVMYQSCJWZCRRLAMRINCGRURGWWUX__
echo ==NETSTAT-START==
SERVER_PID=`docker inspect -f '{{.State.Pid}}' palworld-server_palworld_1`
nsenter -t ${SERVER_PID} -n netstat -su > ${TMP_NETSTAT_OUTPUT}
cat ${TMP_NETSTAT_OUTPUT} | grep "packets received"
cat ${TMP_NETSTAT_OUTPUT} | grep "packets sent"
echo ==NETSTAT-END==

echo ====END====
