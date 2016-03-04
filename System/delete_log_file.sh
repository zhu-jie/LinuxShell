#!/bin/bash
#Author==>Jie
#Email==>adair0101@163.com
#Description=>Delete files older than N days
file="/usr/local/tomcat/log/tomcat_log"
find $file -mtime +30 -name "*.log" -exec rm -rf {} \;
if [ $? = 0 ]
	then 
	echo "Successful operation"
	else
	echo "Unsuccessful"
fi