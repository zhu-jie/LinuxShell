#!/bin/bash
#script  to capture system statistics
OUTFILE=/root/capstats.csv
DATE=`date +%m/%d/%Y`
TIME=`date +%k:%m:%s`
TIMEOUT=`uptime`
VMOUT=`vmstat 1 2`
USERS=`echo $TIMEOUT | awk '{print $6}'`
LOAD=`echo $TIMEOUT | awk '{print $12}' | sed 's/,//'`
FREE=`echo $VMOUT | sed -n '/[0-9]/p' | sed -n '2p' | awk '{print $4}'`
IDLE=`echo  $VMOUT | sed -n '/[0-9]/p' | sed -n '2p' | awk '{print $15}'`
echo "当前系统日期:$DATE
当前系统时间:$TIME
当前连接用户数:$USERS
当前系统15分钟的系统平均负载:$LOAD
当前系统近两秒内的剩余内存:$FREE
当前系统cpu空闲值:$IDLE" >> $OUTFILE

