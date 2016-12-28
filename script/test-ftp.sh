HOST="84.239.97.140"
USER="ipoc"
PASS="passwd!@#"



a=`ftp -vn $HOST << ABC
user $USER $PASS
bye
ABC`

find=`echo $a | grep 230 | grep -v grep | wc -l`


if [ $find -gt 0 ];then
  echo 'success'
  exit 0
else
  echo 'ftp error'
  exit 1
fi
