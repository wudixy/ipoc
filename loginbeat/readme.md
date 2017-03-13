#关于linux系统用户登陆信息的分析

##1. 对应日志
1. /var/log/message
2. /var/log/wtmp
3. /var/log/utmp
4. /var/log/auth


##2. 分析
分析登陆日志，主要用于，安全审计，从安全审计角度来说，知道谁什么时间来了，什么时间走了，还不够完成，还需要知道做了什么，所以需要拿到用户操作记录的日志。

1. 因为用户操作记录的History日志，并不包含时间戳，所以单纯的history log实际上没有作用，需要单独使用脚本记录用户的操作命令，并生成日志文件，例如command.log
2.  utmp log中，记录的是当前登陆用户信息，对于进行历史分析来说，意义不大，并且主体信息同时存储在wtmp中。
3.  wtmp中，记录了从wtmp文件创建以来，所以的登陆记录，包括，登陆类型，用户，ip，设备类型，时间，进程号等
4.  message中，会包含sshd服务的连接信息（用户loging以及Logout的信息），可以通过进程号找到对应关系，包含用户，ip，时间，进程号，但用户从终端直接登陆的信息，无法明确解析出来。
5.  auth中记录登陆失败信息，但此部分信息在message中也有找到。


所以，针对用户登陆信息的日志处理，综合看来，需要：
1. 以wtmp为主，记录loging和logout信息，以message信息为辅。
2. command.log要根据情况取舍，
	a. command log，对应操作比较多的情况，日志量会比较庞大，按照一天1千条命令计算，50台机器，每日就是5万条记录，一年1800万条记录

## 应用场景
login数据主要用于登陆审计

##3. 数据采集
  如果采用message log，使用filebeat捕获/var/log/message文件即可。
  如果采用wtmp，则需要使用c程序读取wtmp文件或者使用shell封装last命令用于根据时间戳捕获变化数据。
  command log，则可以使用HISTTIMEFORMAT，和PROMPT_COMMAND完成
  
###3.1 loginbeat--采用C实现
读取wtmp文件,
接受两个参数：
1. 等待多少秒获取一次数据
2. 一共查询多少次


```cpp

#include <stdio.h>
#include <stdlib.h>
#include <utmp.h>
#include <time.h>
#include <unistd.h>

/* Values for the `ut_type' field of a `struct utmp'.  */
#define EMPTY           0       /* No valid user accounting information. */

#define RUN_LVL         1       /* The system's runlevel. */
#define BOOT_TIME       2       /* Time of system boot.  */
#define NEW_TIME        3       /* Time after system clock changed.  */
#define OLD_TIME        4       /* Time when system clock changed.  */

#define INIT_PROCESS    5       /* Process spawned by the init process.  */
#define LOGIN_PROCESS   6       /* Session leader of a logged in user.  */
#define USER_PROCESS    7       /* Normal process.  */
#define DEAD_PROCESS    8       /* Terminated process.  */

#define ACCOUNTING      9

char* tfile = ".loginbeat.tmp";

int32_t   findstart()  
{  
    FILE   *fp;  
    char   cChar;  
    int   i;  
    char line[20];
    fp=fopen(tfile,"r");  
    if (fp == NULL ) 
    {
       return 0;
    }
    else{
    i=0;  
    cChar=fgetc(fp);  
    while(cChar!='\n' && !feof(fp))  
    {   
        line[i]=cChar;  
        i++;  
        cChar=fgetc(fp);  
    }   
    line[i]='\0';  
    fclose(fp);
    return atol(line);
    } 
} 


void writepos(int32_t pos)
{
    FILE *fp;
    char ch[20];
    if((fp=fopen(tfile,"w"))!=NULL)
    {
       sprintf(ch,"%d",pos);
       fputs(ch, fp);
    }
    //else{
    //   //printf("not open file\n");
    //   return;
    //}
    fclose(fp);
}

void printhead()
{
     printf("----%s\t", "LOGIN_TYPE");
     printf("%s\t", "PID");
     printf("%s\t", "USER");
     printf("%s\t", "HOST");
     printf("%s\t", "DEVICENAME");
     printf("%s\t", "ID");
     printf("%s\t", "SECOND");
     printf("%s\t", "MSECOND");
     printf("%s----\n", "DATETIME");
}

int32_t readLog(int32_t start)
{
   
     struct utmp *p_utent;
     long t;
     int32_t nowtime; 
     time_t timer=time(NULL);
     struct tm *p;
     //char *wday[] = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
     char szBuf[256] = {0};
     nowtime = start;
     utmpname(_PATH_WTMP); /* #define _PATH_WTMP "/var/log/wtmp" */
     //utmpname("/root/log/wtmp"); /* #define _PATH_WTMP "/var/log/wtmp" */
 
     setutent(); /* rewinds the file pointer to the beginning of the utmp file */
     while((p_utent = getutent()) != NULL){
         //if(p_utent->ut_type != USER_PROCESS)
             //continue;
         if (p_utent->ut_tv.tv_sec <= start)
             continue;

             //printf("%d\t", __WORDSIZE);
             //printf("%d\t", __WORDSIZE_COMPAT32);
             timer =p_utent->ut_tv.tv_sec; 
             p = localtime(&timer);
             //printf("%s %d:%d:%d/n", wday[p->tm_wday], p->tm_hour, p->tm_min, p->tm_sec);
             strftime(szBuf, sizeof(szBuf), "%Y-%m-%d %H:%M:%S", localtime(&timer));  
             printf("%s\t", szBuf);  
             printf("%d\t", p_utent->ut_type);
             printf("%d\t", p_utent->ut_pid);
             printf("%s\t", p_utent->ut_user);
             printf("%s\t", p_utent->ut_host);
             printf("%s\t", p_utent->ut_line);
             printf("%s\t", p_utent->ut_id);
             printf("%d\t", p_utent->ut_tv.tv_sec);
             printf("%d\t", p_utent->ut_tv.tv_usec);
             printf("%d\t", p_utent->ut_session);
             t = p_utent->ut_tv.tv_sec;
             nowtime = p_utent->ut_tv.tv_sec;
             printf("%.20s\n", ctime(&t) + 4);
 
     }
    endutent(); /* closes the utmp file. */
    //printf("%d\n",nowtime); 
    return nowtime;
}

int main(int argc, char *argv[])
{
    int sleeptime;
    int count;
    int sc;
    sleeptime = 5;
    count = 1;
    sc = 0;
    //printf("%d\n",argc);
    if (argc != 3 ) 
    {
         printf("must have 2 params,[wait_second] [count]\n");
    }
    else{
         sleeptime = atoi(argv[1]);
         count = atoi(argv[2]);
    }
    //printf("%d\n",sleeptime);
    //printf("%d\n",count);
    int32_t start;
    //printhead();
    while (sc < count){
        start = findstart();
        start = readLog(start);
        writepos(start);
        //printf("%d\n",start);
        sleep(sleeptime);
        sc = sc +1; 
    }
}
```

###3.2 记录command.log 

在/etc/profile中添加
```bash
  HISTDIR='/var/log/command.log'
if [ ! -f $HISTDIR ];then
touch $HISTDIR
chmod 666 $HISTDIR
fi
#export HISTTIMEFORMAT="{\"IP\":\"$SSH_CLIENT $SSH_TTY\",\"TIME\":\"%F %T\",\"HOSTNAME\":\"$HOSTNAME\",\"LI\":\"$(who -u am i 2>/dev/null| awk '{print $NF}'|sed -e 's/[()]//g')\",\"LU\":\"$(who am i|awk '{print $1}')\",\"NU\":\"${USER}\",\"CMD\":\""

export HISTTIMEFORMAT="{\"TIME\":\"%F %T\",\"HOSTNAME\":\"$HOSTNAME\",\"LI\":\"$SSH_CLIENT \",\"TTY\":\"$SSH_TTY\" ,\"LU\":\"$(who am i|awk '{print $1}')\",\"NU\":\"${USER}\",\"CMD\":\""

export PROMPT_COMMAND='history 1|tail -1|sed "s/^[ ]\+[0-9]\+  //"|sed "s/$/\"}/">> /var/log/command.log'
```
其中获取IP地址，上面两个办法都可以
1. 使用who am i命令获取
2. 使用环境变量  $SSH_CLIENT $SSH_TTY,但这种方式对非ssh链接无效，建议使用1
