#!/bin/bash
#author:Jie
#Email:0101adair@gmail.com
d=`date +%Y-%M-%d-%H-%M-%S`
s=`du -k /usr/local/tomcat6/logs/tomcat_log/ |awk '{print $1}'`
logfile="/usr/local/tomcat6/logs/tomcat_log/"
if [ $s -gt 10240 ]
	then
	cd $logfile &&  tar zcvf /home/admin/tomcat_log_bak/tomcat_log_$d.tar.gz  * && cd
	else
	echo "Nothing to do"
fi
# 基本格式 : 
# *　　*　　*　　*　　*　　command 
# 分　时　日　月　周　命令 
#0 1 * * * source /home/admin/sh/tomcat_log.sh &
