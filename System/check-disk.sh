#!/bin/bash
#monitor available disk space
SPACE=`df | sed -n '/\/$/p' | awk '{print $5}' | sed  's/%//'`
if [ $SPACE -ge 90 ]
then
text="你的空间已经不足，请及时处理"
echo "$text" |mail -s space adair0101@163.com
fi

