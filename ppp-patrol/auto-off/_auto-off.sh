#!/bin/bash -e

MY_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
PATROL_PATH=`/usr/bin/dirname ${MY_PATH}`

export COLUMNS=999

mkdir -p ${MY_PATH}/var

YYYYMMDDHHMMSS=${1}
echo ====START====
echo ${YYYYMMDDHHMMSS}

${PATROL_PATH}/venv/bin/python ${PATROL_PATH}/common/timeout_archive_clean.py \
  --folder_path ${MY_PATH}/log \
  --s3_path auto-off-log

UPTIME_TS=`/usr/bin/uptime -s`
UPTIME_TS=`/usr/bin/python3 -c "import datetime;print(int(datetime.datetime.strptime('${UPTIME_TS}','%Y-%m-%d %H:%M:%S').timestamp()))"`
NOW_TS=`/usr/bin/python3 -c "import datetime;print(int(datetime.datetime.strptime('${YYYYMMDDHHMMSS}','%Y%m%d-%H%M%S').timestamp()))"`
GONE_SEC=$((${NOW_TS} - ${UPTIME_TS}))
GONE_SEC_DH=`/usr/bin/python3 -c "print('{:.2f}'.format(${GONE_SEC}/3600))"`

NOW_TS_MDAY=$((${NOW_TS} % 86400))

SERVER_PID=`docker inspect -f '{{.State.Pid}}' palworld-server_palworld_1 || echo NONE`
if [ "${SERVER_PID}" != "NONE" ]; then
  nsenter -t ${SERVER_PID} -n netstat -su > /tmp/netstat__XCNWFIEXGRCALWEVLMYFOZALVRHQQWXW__
else
  rm /tmp/netstat__XCNWFIEXGRCALWEVLMYFOZALVRHQQWXW__
  echo "0 packets received" >> /tmp/netstat__XCNWFIEXGRCALWEVLMYFOZALVRHQQWXW__
  echo "0 packets sent" >> /tmp/netstat__XCNWFIEXGRCALWEVLMYFOZALVRHQQWXW__
fi
PACKETS_RECEIVED=`cat /tmp/netstat__XCNWFIEXGRCALWEVLMYFOZALVRHQQWXW__ | grep "packets received" | sed -e 's/^[[:space:]]*//'`
PACKETS_RECEIVED=(${PACKETS_RECEIVED})
PACKETS_RECEIVED=${PACKETS_RECEIVED[0]}
PACKETS_SENT=`cat /tmp/netstat__XCNWFIEXGRCALWEVLMYFOZALVRHQQWXW__ | grep "packets sent" | sed -e 's/^[[:space:]]*//'`
PACKETS_SENT=(${PACKETS_SENT})
PACKETS_SENT=${PACKETS_SENT[0]}

if [ -f "${MY_PATH}/var/SERVER_PID_1" ]; then
  LAST_SERVER_PID=`cat ${MY_PATH}/var/SERVER_PID_1`
else
  LAST_SERVER_PID="NONE"
fi

if [ -f "${MY_PATH}/var/PACKETS_RECEIVED_1" ]; then
  LAST_PACKETS_RECEIVED=`cat ${MY_PATH}/var/PACKETS_RECEIVED_1`
else
  LAST_PACKETS_RECEIVED="-999999"
fi

if [ -f "${MY_PATH}/var/PACKETS_SENT_1" ]; then
  LAST_PACKETS_SENT=`cat ${MY_PATH}/var/PACKETS_SENT_1`
else
  LAST_PACKETS_SENT="-999999"
fi

if [ -f "${MY_PATH}/var/SERVER_PID_0" ]; then
  cp ${MY_PATH}/var/SERVER_PID_0 ${MY_PATH}/var/SERVER_PID_1
fi
if [ -f "${MY_PATH}/var/PACKETS_RECEIVED_0" ]; then
  cp ${MY_PATH}/var/PACKETS_RECEIVED_0 ${MY_PATH}/var/PACKETS_RECEIVED_1
fi
if [ -f "${MY_PATH}/var/PACKETS_SENT_0" ]; then
  cp ${MY_PATH}/var/PACKETS_SENT_0 ${MY_PATH}/var/PACKETS_SENT_1
fi

if [ -f "/home/ubuntu/nooff" ]; then
  NOOFF=1
else
  NOOFF=0
fi

PACKETS_RECEIVED_DIFF=$((${PACKETS_RECEIVED} - ${LAST_PACKETS_RECEIVED}))
PACKETS_SENT_DIFF=$((${PACKETS_SENT} - ${LAST_PACKETS_SENT}))

echo ${SERVER_PID} > ${MY_PATH}/var/SERVER_PID_0
echo ${PACKETS_RECEIVED} > ${MY_PATH}/var/PACKETS_RECEIVED_0
echo ${PACKETS_SENT} > ${MY_PATH}/var/PACKETS_SENT_0

echo UPTIME_TS=${UPTIME_TS}
echo NOW_TS=${NOW_TS}
echo GONE_SEC=${GONE_SEC}
echo NOW_TS_MDAY=${NOW_TS_MDAY}

echo LAST_SERVER_PID=${LAST_SERVER_PID}
echo SERVER_PID=${SERVER_PID}

echo LAST_PACKETS_RECEIVED=${LAST_PACKETS_RECEIVED}
echo PACKETS_RECEIVED=${PACKETS_RECEIVED}
echo PACKETS_RECEIVED_DIFF=${PACKETS_RECEIVED_DIFF}

echo LAST_PACKETS_SENT=${LAST_PACKETS_SENT}
echo PACKETS_SENT=${PACKETS_SENT}
echo PACKETS_SENT_DIFF=${PACKETS_SENT_DIFF}

DO_SHUTDOWN=1

#if [ "${NOW_TS_MDAY}" -lt "57600" ]; then
#  echo BEFORE UTC 16:00
#  DO_SHUTDOWN=0
#fi

if [ "${NOOFF}" == "1" ]; then
  echo NO-OFF enabled
  DO_SHUTDOWN=0
fi

if [ "${SERVER_PID}" == "NONE" ]; then
  echo NO SERVER RUNNING
  DO_SHUTDOWN=0
fi

if [ "${GONE_SEC}" -lt "900" ]; then
  echo GONE_SEC less than 15min
  DO_SHUTDOWN=0
fi

if [ "${SERVER_PID}" != "${LAST_SERVER_PID}" ]; then
  echo SERVER_PID changed
  DO_SHUTDOWN=0
fi

if [ "${PACKETS_RECEIVED_DIFF}" -gt "300" ]; then
  echo PACKETS_RECEIVED_DIFF high
  DO_SHUTDOWN=0
fi

if [ "${PACKETS_SENT_DIFF}" -gt "300" ]; then
  echo PACKETS_SENT_DIFF high
  DO_SHUTDOWN=0
fi

if [ "${DO_SHUTDOWN}" == "1" ]; then
  echo SHUTDOWN
  ${PATROL_PATH}/venv/bin/python ${PATROL_PATH}/common/broadcast.py NOTICE "PP園區光榮關閉中♪ 營運時間:${GONE_SEC}s=${GONE_SEC_DH}h"
  docker container stop palworld-server_palworld_1
  shutdown -h now
fi

echo ====END====
