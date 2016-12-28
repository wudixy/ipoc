# ipoc 服务端的设置

## base setting
/opt/iPOC30/config/setup.ini
```
cfgDir=/opt/iPOC30/config
binDir=/opt/iPOC30/bin
ftpDir=/home
ftpbak=/data/ftpbak
bufDir=/data/buffer
bigDir=/data/big
awrWWW=/data/wwwawr
webDir=/var/www/html
logDir=/data/log
awrDir=/data/awr
baklog=/data/bak-log
bakawr=/data/bak-awr
tempDir=/dev/shm
```

## user setting
/opt/iPOC30/config/passport.txt
format:
username,password,groupid,end

path需要对应setup.ini中bigDir下的一个子目录或Link


## 自定义web页面
$webDir/user/sss/favor.home
```
SAP|prs07,CPU_ALL|
SAP|prs09,CPU_ALL|
SAP|CSMESDB01,CPU_ALL|
SAP|prs07,NET_ALL|
CSMES1|CSMESDB01,CPU_ALL|
CSMES1|CSMESDB01,NET_ALL|
CSMES1|CSMESDB01,MB_ALL|
CSMES1|CSMESDB01,TPS_ALL|
```

## ipoc组织形式
1. domain 一个域通常意味客户一组环境，包含多台主机或设备，他们的数据通常同时计算
2. group 一个组，可以理解为将一个domain中的不同机器按照不同的组织架构进行展示，例如核心系统，手付费系统

通常，
1. 我们针对一个客户的所以设备建立一个或多个大的domain，他们对应ipoc服务器的一个账户，所有的数据发送到这个账户的设定目录。针对这个用户设定crontab调度计划，执行数据解析计算程序
例如，建立一个ipoc的domain，在操作系统对应建一个ipoc的目录，其所有原始日志先放入/home/ipoc缓存，然后定时任务每隔一定时间间隔解析这些数据，并
    a. 将数据放入$logDir/ipoc中
    b. 将解析好的数据放入$bigdir/ipoc中
此时，我们可以建一个ipoc的web用户，可以login web页面，并查看所有机器的信息

2. 根据不同的组织形态，例如我们希望将核心系统的数据单独建一个用户(bruce)查看，可以
    a. 在$bigdir/ipoc中新建一个hostset.bruce,并将需要的主机hostname添加进去
    b. cp $webDir/user/ipoc $webdir/user/bruce
    c. 在/opt/iPOC30/config/passport.txt中添加bruce,password,bruce,end
    d. 此时在web页面，即可使用bruce这个账户登陆，并查看指定主机的各种性能数据

# ipoc中添加一台主机到已有的domain或group
1. 在新主机上部署采集脚本，并传输数据到指定目录
2. 需要编辑对应的$logdir/path/hostset.[nmon,ms,linux],添加新的hostname
3. 编辑对应的$bigdir/path/hostset.[nmon,ms,linux]，添加新的hostname
