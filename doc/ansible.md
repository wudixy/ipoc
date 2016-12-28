
#本文记录使用ansible配置部署IPOC
(http://www.ansible.com.cn/docs/intro_inventory.html)

# install

## ubuntu
sudo apt-get update
sudo apt-get install ansible
## centos & readhat
1. set epel; 
```
rpm -iUvh http://dl.Fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm; 
```
>可能需要自己到上述网址查一下当前的版本是多少，例如上面命令中的.7.8
2. yum install ansible

## 手工安装
1. 使用yumdownloader下载ansible，然后安装，常见的依赖是
```
ansible-2.2.0.0-4.el7.noarch.rpm
libyaml-0.1.4-11.el7_0.i686.rpm
libyaml-0.1.4-11.el7_0.x86_64.rpm
python2-pyasn1-0.1.9-7.el7.noarch.rpm
python-babel-0.9.6-8.el7.noarch.rpm
python-crypto-2.6.1-1.el7.centos.x86_64.rpm
python-ecdsa-0.11-3.el7.centos.noarch.rpm
python-httplib2-0.7.7-3.el7.noarch.rpm
python-jinja2-2.7.2-2.el7.noarch.rpm
python-keyczar-0.71c-2.el7.noarch.rpm
python-markupsafe-0.11-10.el7.x86_64.rpm
python-paramiko-1.12.4-1.el7.centos.noarch.rpm
PyYAML-3.10-11.el7.x86_64.rpm
sshpass-1.05-5.el7.x86_64.rpm
```
2. install rpm
```
rpm -ivh ***.rpm
```

# useansible 

## config host and access
1. edit /etc/ansible/hosts,and add you host setting,like
```
[DB_ODS] #group name
nopplocr29   ansible_ssh_host=84.239.71.24 database=True ansible_ssh_pass=appmon
nopplocr30   ansible_ssh_host=84.239.71.25 database=True ansible_ssh_pass=appmon
```
hosts文件设置有很多技巧和方法，具体参考ansible文档，需要说明和记录的是：
a. 如果配置中没有指定用户名，则链接时默认使用当前用户,可以这样测试
```
   ansible nopplocr29 -m ping or
   ansible nopplocr29 -m ping -u appmon
   ansible nopplocr29 -m ping -u appmon -k
```
b. 如果配置中没有指定密码，则链接时，需要配置无密码ssh访问，可以这样配置无密码访问
```
ssh-keygen -t rsa
ssh-copy-id -i ~/.ssh/id_rsa.pub remoteuser@remotehost
```
2. test 
```
# as bruce
$ ansible all -m ping -u appmon
# as bruce, sudoing to root
$ ansible all -m ping -u bruce --sudo
# as bruce, sudoing to batman
$ ansible all -m ping -u bruce --sudo --sudo-user batman
$ ansible all -a "/bin/echo hello"
```
## ansible playbook
例如上面例子中的  ansible -m ping/setup/,这些都是ansible提供的模块，可以直接使用，并获取返回值，例如
```
ansible all -m setup | more
可以看到目标机器的需要设置，例如hostname,ip,datetime,os version等
```
但仅仅如此使用，ansible 就大才小用了。ansible 中我们可以通过配置playbook配置文件，制定ansible在目标机器的各种操作组合，例如copy文件，执行脚本，启动服务，检查操作系统属性等

以下为部署ipoc时的一个配置文件
说明：
1. 文件格式是yml格式，格式说明参考yml语法
```
---
#ipoc自动部署配置,nmon,传输脚本，crontab
#wudi 20161223
- hosts: DB_WECHAT #要操作的机器列表或者组 
  gather_facts: yes  #显示facts输出
  vars: #变量定义
      srcbasedir: /home/wudi/ipoc/icbc-axa-online
      desthomedir: /home/appmon/ipoc
      killnmon: True  #是否kill已有的nmon进程
      startnmon: True  #是否立即启动nmon捕获数据到当天24点
  remote_user: appmon #远程用户定义
  tasks:
      #循环创建目录,如果路径已存在，ansible不会再创建，这避免了自己写shell脚本需要做的判断
      - name : create dir 
        file : path={{item}} state=directory mode=0755
        with_items:
                - ipoc
                - "{{ desthomedir }}/bin"
                - "{{ desthomedir }}/nmondata"

      #根据操作系统版本选择要传输的nmon介质，在ansible执行最开始的动作时，会发现ansible会自动执行一个setup的动作，这个动作会获取目标主机的基础信息，例如下面配置中用到的ansible_distribution
      - name : 传输nmon put nmon @CENTOS7 or @RedHat7
        copy: src={{ srcbasedir }}/nmonkit/nmon16e_x86_rhel72 dest={{ desthomedir }}/bin/nmon mode="u=rwx"
        when: (ansible_distribution == 'RedHat' or ansible_distribution == 'CentOS') and ansible_distribution_major_version == "7"
      - name : 传输nmon  put nmon @CENTOS6 or @Redhat6
        copy: src={{ srcbasedir }}/nmonkit/nmon16e_x86_rhel65 dest={{ desthomedir }}/bin/nmon mode="u=rwx"

        when: (ansible_distribution == 'RedHat' or ansible_distribution == 'CentOS') and ansible_distribution_major_version == "6"
      - name : 传输nmon  put nmon @CENTOS5 or @RedHat5
        copy: src={{ srcbasedir }}/nmonkit/nmon_x86_64_rhel54 dest={{ desthomedir }}/bin/nmon mode="u=rwx"

        when: (ansible_distribution == 'RedHat' or ansible_distribution == 'CentOS') and ansible_distribution_major_version == "5"
      - name : 传输nmon  put nmon @SLES11
        copy: src={{ srcbasedir }}/nmonkit/nmon16e_x86_sles113 dest={{ desthomedir }}/bin/nmon mode="u=rwx"

        when: ansible_distribution == 'SLES' and ansible_distribution_major_version == "11"
      - name : 传输nmon  put nmon @SLES10
        copy: src={{ srcbasedir }}/nmonkit/nmon_x86_64_sles11_oldest dest={{ desthomedir }}/bin/nmon mode="u=rwx"
        when: ansible_distribution == 'SLES' and ansible_distribution_major_version == "10"

      #传输脚本程序，并赋执行
      - name : 传输脚本 
        copy : src={{ srcbasedir }}/script/{{item}} dest={{ desthomedir }}/bin/{{item}} mode="u=rwx"
        with_items:
                - snmon_nowto24.sh
                - v30-nmon2ipoc.sh

      - name : 停止已有采集脚本
        command : ps -ef | grep {{ desthomedir }}/bin/nmon | grep -v grep | awk '{print $2}' | xargs kill
	#正常情况下,ansible顺序执行配置的task，遇到错误则停止，此处通过配置ignore_errors属性，忽略此task的错误
        ignore_errors: yes 
        when: "{{ killnmon }} == True"

      # 使用shell模块，在远程启动脚本，并根据变量startnmon的值来决定是否启动
      - name : 调用脚本,启动NMON采集数据call snmon_nowto24.sh
        shell : "{{ desthomedir }}/bin/snmon_nowto24.sh"
        when: "{{ startnmon }} == True"

      # 使用cron模块，添加crontab定义，当重复执行这个task时，会根据name属性判断是否是同一个配置，对于同一个配置，ansible会根据是否变化决定是否更新
      - name : 添加nmon到crontab add crontab
        cron : "name='ipoc_nmon' minute=0 hour=0 job='{{ desthomedir }}/bin/nmon -f -t -s 60 -c 1440 -m {{ desthomedir }}/nmondata > /dev/null 2>&1' user=appmon"

      - name : 添加传输脚本到crontab add crontab v30-nmon2ipoc.sh
        cron : "name='ipoc_ftp_nmondata to logcenter' minute=5 job='{{ desthomedir }}/bin/v30-nmon2ipoc.sh' user=appmon"

      - name : sleep wait nmon make data
        command : sleep 1

      - name : sentData2ipoc
        shell : "{{ desthomedir }}/bin/v30-nmon2ipoc.sh"

      # 对数据数据库，额外增添如下处理AWR的动作 
      - name : copy v30-awr2ipoc.sh to target hosts
        copy : src={{ srcbasedir }}/script/{{item}} dest={{ desthomedir }}/bin/{{item}} mode="u=rwx"
        with_items:
               - v30-awr2ipoc.sh
               - v30-awr2ipoc-allsid.sh
        when: database $如果是数据库（定义了布尔类型的变量database），则执行本task

      - name : add crontab
        cron : "name='ipoc_ftp_awrdata' minute=6  job='{{desthomedir}}/bin/v30-awr2ipoc-allsid.sh'"
        when: database
    
      - name : execute v30-awr2ipoc.sh
        shell : "{{desthomedir}}/bin/v30-awr2ipoc-allsid.sh"
        when: database
```
