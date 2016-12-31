#!/bin/bash
BASEDIR=/home/appmon/ipoc

################################################
# config contab
################################################
PROGRAM=$BASEDIR/bin/nmon
CRONTAB_CMD="0 0 * * * $PROGRAM -f -t -s 60 -c 1440 -m /home/appmon/ipoc/nmondata > /dev/null 2>&1"
PROGRAM2=$BASEDIR/bin/v30-nmon2ipoc.sh
CRONTAB_CMD2="5 * * * * $PROGRAM2"
(crontab -l 2>/dev/null |grep -v '^#'|grep -Fv $PROGRAM; echo "$CRONTAB_CMD"; echo "$CRONTAB_CMD2") | crontab -
COUNT=`crontab -l | grep $PROGRAM | grep -v "grep"|wc -l `
if [ $COUNT -lt 1 ]; then
    echo "fail to add crontab" 
    echo 'pls use crontab -e,add config like:'
    echo "0 0 * * * ${BASEDIR}/bin/nmon -f -t -s 60 -c 1440 -m ${BASEDIR}/nmondata > /dev/null 2>&1'
    echo '5 * * * * ${BASEDIR}/bin/v30-nmon2ipoc.sh'
    exit 1
fi
echo '-----step3:config crontab sucess------------'
