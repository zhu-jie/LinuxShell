#!/bin/bash
#description:获取局域网内ip和mac的对应关系
NADD="192.168.1."
FILE="/etc/ethers"
[ -f $FILE ] && /bin/cp -f $FILE $FILE.old
HADD=99
while [ $HADD -lt 199 ]
do
  	arping -c 2 -w 1 ${NADD}${HADD} &> /dev/null
  	if [ $? -eq 0 ] 
  		then
     		arp -n | grep ${NADD}${HADD} | awk '{print $1,$3}' >> $FILE
  	fi
  	let HADD++
done
