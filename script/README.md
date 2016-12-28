# collect
 日志收集脚本

# checknmon.sh
 配合ansible，检查当前是否有nmon正在运行

#deploy_oldversion
 老的ipoc部署脚本，已不使用

# getminuts.sh
 获取当前系统时间，并计算到24点还有多少分钟，并返回

# snmon_nowto24.sh
  从当前时间启动nmon,并采集到晚上12点


# v30-awr2ipoc-allsid.sh and v30-awr2ipoc.sh
  v30-awr2ipoc.sh 接收一个sid的参数，传输，压缩对应sid的awrlog
  v30-awr2ipoc-allsid.sh 自动到awr目录判断一共有多少sid，并循环调用上述shell传输数据
  
# v30-nmon2ipoc.sh
  传输nmon数据到日志服务器

# mkhostlist.sh
根据传入的配置文件，批量生成ansible_hosts文件
配置文件通常是一组目标IP的地址
```
84.239.49.154
84.239.49.156
84.239.97.97
84.239.97.98
84.239.97.150
84.239.97.151
84.239.97.65
84.239.97.66
```

# sshcopid.sh
根据传入的host文件，批量COPY id_rsa.pub到目标机器，配置无密码访问

# v30-backupnmon2ipoc.sh
将~/ipoc/nmon/backup中的内容（历史数据）传输至日志中心

# killnmon.sh
杀死当前主机上的Nmon程序，通常配置ansible使用
ansible host -m script -a "killnmon.sh"
