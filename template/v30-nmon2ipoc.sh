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

nmonDir="{{ desthomedir }}/nmondata"
################################################################
### ftp /var/log/nmon/*.nmon to iPOC_ftp /home/turboteam
################################################################
cd $nmonDir
ftp -in $HOST << ABC
user $USER $PASS
binary
mput *.nmon
bye
ABC

if [ ! -d $nmonDir/backup ] ; then
    mkdir $nmonDir/backup
fi

ls $nmonDir | grep -q $yesterday

if [[ $? -eq 0 ]] ; then
    tar czf $nmonDir/backup/$servername-$YESTERDAY.tar.gz *$yesterday*.nmon
    mv  $nmonDir/*$yesterday*.nmon $nmonDir/backup
#    rm  $nmonDir/*$yesterday*.nmon
#    rm  $nmonDir/backup/$servername-$day30.tar.gz
    find $nmonDir/backup/ -mtime +30 -type f | xargs rm -rf
fi
