#!/bin/bash -e

export COLUMNS=999
YYYYMMDDHHMMSS=${1}

MY_PATH=`/usr/bin/dirname ${0}`
PATROL_PATH=`/usr/bin/dirname ${MY_PATH}`

echo ====START====
echo ${YYYYMMDDHHMMSS}

echo ==CLEAN-START==
${PATROL_PATH}/venv/bin/python ${PATROL_PATH}/common/timeout_archive_clean.py ${MY_PATH}/log stat
echo ==CLEAN-END==

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
