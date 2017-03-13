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
        //utmpname("/root/log/wtmp"); /* #define _PATH_WTMP "/var/log/wtmp" */
 
        setutent(); /* rewinds the file pointer to the beginning of the utmp file */
        while((p_utent = getutent()) != NULL){
                //if(p_utent->ut_type != USER_PROCESS)
                    //continue;
		if (p_utent->ut_tv.tv_sec <= start)
			continue;

                printf("%d\t", __WORDSIZE);
                printf("%d\t", __WORDSIZE_COMPAT32);

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

int main()
{
	int32_t start;
        printhead();
	while (1==1){
                start = findstart();
		start = readLog(start);
		writepos(start);
		//printf("%d\n",start);
	        sleep(1);	
	}
}
