#!/bin/ksh
AWR_HOME=/home/oracle				### need modify
ORACLE_SID=ABC					### instance name: need to modify
Yesterday=` perl -e 'use POSIX qw(strftime);print strftime "%y%m%d\n", localtime(time-86400)'    `
Day7=` perl -e 'use POSIX qw(strftime);print strftime "%y%m%d\n", localtime(time-86400*7)'    `

cd $AWR_HOME
tar -cf $ORACLE_SID-AWR-$Yesterday.tar $ORACLE_SID*$Yesterday*.html
gzip -f  $ORACLE_SID-AWR-$Yesterday.tar


###################################### 
###### put zip file to ftpserver ##### 
###################################### 
FTPserver="192.168.xx.xxx"	     		### need the change
FTPUSER="XXXX"                       		### need change
FTPPASS="YYYY"                       		### need change
ftp -inv $FTPserver << EOF
user $FTPUSER $FTPPASS
binary
put  $ORACLE_SID-AWR-$Yesterday.tar.gz
bye
EOF

###################################### 
###### delete 7days ago log & zip  ### 
###################################### 
rm -rf $ORACLE_SID-AWR-$Day7.tar.gz		###
#rm $ORACLE_SID*$Yesterday*.html		###
exit