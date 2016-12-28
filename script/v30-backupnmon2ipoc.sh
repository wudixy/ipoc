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

nmonDir="/home/appmon/ipoc/nmondata"
################################################################
### ftp /var/log/nmon/*.nmon to iPOC_ftp /home/turboteam
################################################################
cd $nmonDir/backup
ftp -in $HOST << ABC
user $USER $PASS
binary
mput *.nmon
bye
ABC
