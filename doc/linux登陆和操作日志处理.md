## linux登陆相关日志

[参考链接](http://blog.chinaunix.net/uid-25909722-id-2851379.html)


开发loginbeat，用于读取持续读取当前登陆记录，并输出到标准输出

loginbeat.c,编译为可执行文件,gcc loginbeat.c -o loginbeat
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
    while(cChar!='\n'   &&   !feof(fp))  
    {   
        line[i]=cChar;  
        i++;  
        cChar=fgetc(fp);  
    }   
    line[i]='\0';  
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
	nowtime = start;
        utmpname(_PATH_WTMP); /* #define _PATH_WTMP "/var/log/wtmp" */
 
        setutent(); /* rewinds the file pointer to the beginning of the utmp file */
        while((p_utent = getutent()) != NULL){
                //if(p_utent->ut_type != USER_PROCESS)
                    //continue;
		if (p_utent->ut_tv.tv_sec <= start)
			continue;

                printf("%d\t", p_utent->ut_type);
                printf("%d\t", p_utent->ut_pid);
                printf("%s\t", p_utent->ut_user);
                printf("%s\t", p_utent->ut_host);
                printf("%s\t", p_utent->ut_line);
                printf("%s\t", p_utent->ut_id);
                printf("%d\t", p_utent->ut_tv.tv_sec);
                printf("%d\t", p_utent->ut_tv.tv_usec);
                t = p_utent->ut_tv.tv_sec;
                nowtime = p_utent->ut_tv.tv_sec;
                printf("%.20s\n", ctime(&t) + 4);
 
        }
        endutent(); /* closes the utmp file. */
        //printf("%d\n",nowtime); 
        return nowtime;
}

int main()
{
	int32_t start;
        printhead();
	while (1==1){
                start = findstart();
		start = readLog(start);
		writepos(start);
		//printf("%d\n",start);
	        sleep(5);	
	}
}
```

##收集用户命令操作历史记录

编辑/etc/profile,添加如下内容
```bash
HISTDIR='/var/log/command.log'
if [ ! -f $HISTDIR ];then
touch $HISTDIR
chmod 666 $HISTDIR
fi
export HISTTIMEFORMAT="{\"TIME\":\"%F %T\",\"HOSTNAME\":\"$HOSTNAME\",\"LI\":\"$(who -u am i 2>/dev/null| awk '{print $NF}'|sed -e 's/[()]//g')\",\"LU\":\"$(who am i|awk '{print $1}')\",\"NU\":\"${USER}\",\"CMD\":\""
export PROMPT_COMMAND='history 1|tail -1|sed "s/^[ ]\+[0-9]\+  //"|sed "s/$/\"}/">> /var/log/command.log'
```


cat /var/log/command.log
```
{"TIME":"2017-03-02 08:16:06","HOSTNAME":"suse87","LI":"192.168.0.106","LU":"root","NU":"root","CMD":"vi tmp.sh "}
{"TIME":"2017-03-02 08:47:59","HOSTNAME":"suse87","LI":"192.168.0.106","LU":"root","NU":"root","CMD":"ls"}
{"TIME":"2017-03-02 08:48:02","HOSTNAME":"suse87","LI":"192.168.0.106","LU":"root","NU":"root","CMD":"hostnam,e"}
{"TIME":"2017-03-02 08:48:04","HOSTNAME":"suse87","LI":"192.168.0.106","LU":"root","NU":"root","CMD":"hostname"}
{"TIME":"2017-03-02 08:48:08","HOSTNAME":"suse87","LI":"192.168.0.106","LU":"root","NU":"root","CMD":"test"}
{"TIME":"2017-03-02 08:48:19","HOSTNAME":"suse87","LI":"192.168.0.106","LU":"root","NU":"root","CMD":"pwd"}
{"TIME":"2017-03-02 08:48:20","HOSTNAME":"suse87","LI":"192.168.0.106","LU":"root","NU":"root","CMD":"ls"}
{"TIME":"2017-03-02 08:48:24","HOSTNAME":"suse87","LI":"192.168.0.106","LU":"root","NU":"root","CMD":"cd "}
{"TIME":"2017-03-02 08:48:26","HOSTNAME":"suse87","LI":"192.168.0.106","LU":"root","NU":"root","CMD":"ls"}
{"TIME":"2017-03-02 08:49:18","HOSTNAME":"suse87","LI":"192.168.0.106","LU":"root","NU":"root","CMD":"pwd"}
{"TIME":"2017-03-02 08:49:19","HOSTNAME":"suse87","LI":"192.168.0.106","LU":"root","NU":"root","CMD":"ls"}
{"TIME":"2017-03-02 08:49:58","HOSTNAME":"suse87","LI":":0.0","LU":"root","NU":"root","CMD":"source tmp.sh "}
{"TIME":"2017-03-02 08:50:02","HOSTNAME":"suse87","LI":":0.0","LU":"root","NU":"root","CMD":"cd /"}
{"TIME":"2017-03-02 08:49:19","HOSTNAME":"suse87","LI":"192.168.0.106","LU":"root","NU":"root","CMD":"ls"}
{"TIME":"2017-03-02 08:51:25","HOSTNAME":"suse87","LI":":0.0","LU":"root","NU":"root","CMD":"pwd"}
{"TIME":"2017-03-02 08:49:19","HOSTNAME":"suse87","LI":"192.168.0.106","LU":"root","NU":"root","CMD":"ls"}
{"TIME":"2017-03-02 08:51:59","HOSTNAME":"suse87","LI":"192.168.0.106","LU":"root","NU":"root","CMD":"cd log/"}
{"TIME":"2017-03-02 08:52:00","HOSTNAME":"suse87","LI":"192.168.0.106","LU":"root","NU":"root","CMD":"ls"}
{"TIME":"2017-03-02 08:52:02","HOSTNAME":"suse87","LI":"192.168.0.106","LU":"root","NU":"root","CMD":"cd "}
```