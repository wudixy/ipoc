#!/bin/bash
################################################
### set env
################################################
TODAY=`date +%Y%m%d`
today=`date +%y%m%d`
YESTERDAY=`date -d "yesterday" +%Y%m%d`
yesterday=`date -d "yesterday" +%y%m%d`
day30=` perl -e 'use POSIX qw(strftime);print strftime "%y%m%d\n", localtime(time-86400*30)'    `
servername=`hostname`
HOST="84.239.97.140"
USER="ipoc"
PASS="passwd!@#"

AWRDIR="/home/appmon/awrlog"

ORACLE_SID=$1
cd $AWRDIR
tar -cf $AWRDIR/$ORACLE_SID-AWR-$TODAY.tar $ORACLE_SID*$today*.html
gzip -f $AWRDIR/$ORACLE_SID-AWR-$TODAY.tar
tar -cf $AWRDIR/$ORACLE_SID-AWR-$YESTERDAY.tar $ORACLE_SID*$yesterday*.html
gzip -f $AWRDIR/$ORACLE_SID-AWR-$YESTERDAY.tar

#scp $AWR_TAR_HOME/$ORACLE_SID-AWR-$YESTERDAY.tar.gz $AWR_TAR_HOME/$ORACLE_SID-AWR-$TODAY.tar.gz  $USER@$HOST:~
################################################################
### ftp /var/log/nmon/*.nmon to iPOC_ftp /home/turboteam
################################################################
cd $AWRDIR
ftp -in $HOST << ABC
user $USER $PASS
binary
put $ORACLE_SID-AWR-$TODAY.tar.gz
put $ORACLE_SID-AWR-$YESTERDAY.tar.gz
bye
ABC

find $AWRDIR/ -mtime +30 -type f | xargs rm -rf

