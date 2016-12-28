#!/bin/bash
BASEDIR=~/ipoc
REMOTE_HOST=84.239.97.140
REMOTE_USER="ipoc"
REMOTE_PWD="passwd!@#"
REMOTE_DKIT=/data/rhel65dkit

################################################
# check and create ipoc BASEDIR 
################################################
if [ ! -d $BASEDIR ] ; then
   echo 'create ipoc base dir'
   mkdir $BASEDIR
else
   echo 'base dir already exits'
   exit 0
fi

mkdir $BASEDIR/nmondata
mkdir $BASEDIR/bin

echo '-------step1:make base dir sucess--------------'
################################################
# ftp get bin file
################################################
cd $BASEDIR/bin
ftp -in $REMOTE_HOST<<EOF
user $REMOTE_USER $REMOTE_PWD
binary
cd $REMOTE_DKIT
mget *
bye
EOF
echo '------step2:ftp get scprit sucess-------------'
################################################
# add x
################################################
chmod +x $BASEDIR/bin/*
nname=`ls | grep nmon16e`
ln -s $nname nmon

################################################
# config contab
################################################
PROGRAM=$BASEDIR/bin/nmon
CRONTAB_CMD="0 0 * * * $PROGRAM -f -t -s 60 -c 1440 -m /home/appmon/ipoc/nmondata > /dev/null 2>&1"
PROGRAM2=$BASEDIR/bin/v30-nmon2ipoc.sh
CRONTAB_CMD2="5 * * * * $PROGRAM2"
PROGRAM3=$BASEDIR/bin/v30-awr2ipoc.sh
CRONTAB_CMD3="6 * * * * $PROGRAM3"
(crontab -l 2>/dev/null |grep -v '^#'|grep -Fv $PROGRAM; echo "$CRONTAB_CMD"; echo "$CRONTAB_CMD2"; echo "$CRONTAB_CMD3") | crontab -
COUNT=`crontab -l | grep $PROGRAM | grep -v "grep"|wc -l `
if [ $COUNT -lt 1 ]; then
        echo "fail to add crontab" 
    echo 'pls use crontab -e,add config like:'
    echo '0 0 * * * /home/appmon/ipoc//bin/nmon -f -t -s 60 -c 1440 -m /home/appmon/ipoc/nmondata > /dev/null 2>&1'
    echo '5 * * * * /home/appmon/ipoc/bin/v30-nmon2ipoc.sh'
        exit 1
fi
echo '-----step3:config crontab sucess------------'

s=`date +%Y-%m-%d%t%H:%M:%S`
s2=`date +%Y-%m-%d`' 23:59:00'
start=`date +%s -d "$s"`
#start=`date +%s -d "2011-11-28 15:00:37"`
#end=`date +%s -d "2011-11-28 23:59:00"`
end=`date +%s -d "$s2"`
#echo $(($end-$start))
num3=$(($end-$start))
#echo $num3

num4=`expr $num3 / 60`
echo $num4

echo '----step4:start script----------------------'
$PROGRAM -f -t -s 60 -c $num4 -m /home/appmon/ipoc/nmondata > /dev/null 2>&1
sleep 5
$PROGRAM2
