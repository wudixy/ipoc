# awr_collect
 收集awr日志脚本

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
