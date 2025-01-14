#!/bin/sh

ROOTER=/usr/lib/rooter

log() {
	logger -t "sms process" "$@"
}

CURRMODEM=$(uci get modem.general.smsnum)

DEST="$1"
shift 1
TXT="$@"
MYPID=$(printf "%05d" $$)
MYPID=$(printf "${MYPID:1:4}")
RESFILE="/tmp/smssendstatus"$MYPID

lua /usr/lib/sms/smsout.lua $CURRMODEM $DEST "$TXT" $MYPID
sleep 5
COUNT=0
XSTATUS=1
RES="信息发送失败，读取结果超时"
while [ $COUNT -lt 15 ]; do
	if [ -e $RESFILE ]; then
		read RES < $RESFILE
		if [ "${RES:0:9}" = "已发送信息," ]; then
			XSTATUS=0
		fi
		COUNT=999
		rm $RESFILE
	else
		sleep 2
	fi
	COUNT=$(($COUNT + 1))
done
log "$RES"
echo "$RES"
exit $XSTATUS
