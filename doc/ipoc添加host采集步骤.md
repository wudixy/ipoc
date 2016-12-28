#ipoc添加host采集步骤

1. 检查操作系统版本,选择nmon版本或使用脚本采集日志

```
[root@3.5.5Biz-46 ~]# lsb_release -a 
LSB Version: 1.3
Distributor ID: RedHatEnterpriseAS
Description: Red Hat Enterprise Linux AS release 4 (Nahant Update 1)
Release: 4
Codename: NahantUpdate1
[root@3.5.5Biz-46 ~]# 

登录到linux执行cat /etc/redhat-release ，例如如下：
[root@3.5.5Biz-46 ~]# cat /etc/redhat-release 
Red Hat Enterprise Linux AS release 4 (Nahant Update 1)

```

2. 根据1的结果选择nmon版本
[nmon下载链接] (http://nmon.sourceforge.net/pmwiki.php)


3. 上传nmon到目标服务器，并重命名为nmon或使用连接
```
ln -s nmon_version_16n nmon
```

4. 上传v30-nmon2ipoc.sh到目标机器

5. 创建目录/home/appmon/nmondata  
```
mkdir nmondata
```

6. 配置crontab,定时调度a,b
``` 
0 0 * * * /home/appmon/nmon -f -t -s 60 -c 1440 -m /home/appmon/nmondata > /dev/null 2>&1
5 * * * * /home/appmon/v30-nmon2ipoc.sh
```


#脚本v30-nmon2ipoc.sh
```
#!/bin/bash
BASEDIR=~/ipoc
REMOTE_HOST=123.123.123.123
REMOTE_USER="ipoc"
REMOTE_PWD="password"
REMOTE_DKIT=/data/ipocDkit

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

################################################
# add x
################################################
chmod +x $BASEDIR/bin/*
nname=`ls | grep nmon16`
ln -s $nname nmon

################################################
# config contab
################################################
PROGRAM=$BASEDIR/bin/nmon
CRONTAB_CMD="0 0 * * * $PROGRAM -f -t -s 60 -c 1440 -m /home/appmon/ipoc/nmondata > /dev/null 2>&1"
PROGRAM2=$BASEDIR/bin/v30-nmon2ipoc.sh
CRONTAB_CMD2="5 * * * * $PROGRAM"
(crontab -l 2>/dev/null |grep -v '^#'|grep -Fv $PROGRAM; echo "$CRONTAB_CMD"; echo "$CRONTAB_CMD2") | crontab -
COUNT=`crontab -l | grep $PROGRAM | grep -v "grep"|wc -l `
if [ $COUNT -lt 1 ]; then
        echo "fail to add crontab" 
    echo 'pls use crontab -e,add config like:'
    echo '0 0 * * * /home/appmon/ipoc//bin/nmon -f -t -s 60 -c 1440 -m /home/appmon/ipoc/nmondata > /dev/null 2>&1'
    echo '5 * * * * /home/appmon/ipoc/bin/v30-nmon2ipoc.sh'
        exit 1
fi

```
