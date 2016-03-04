#!/bin/bash
#author:Jie
#Email:0101adair@gmail.com
#This script for other peopel
netstat -an| grep :80 |grep -v -E '127.0|0.0|10.0'|awk '{ print $5 }' | sort|awk -F: '{print $1}' | uniq -c | awk '$1' | awk '$2 != ""' >/usr/local/ddos/black.txt
cnt=0
for i in `awk '{print $2}' /usr/local/ddos/black.txt`
do
  if [ ! -z "$i" ];
  then
          COUNT=`grep $i /usr/local/ddos/black.txt | awk '{print \$1}'`
          DEFINE="20"
          ZERO="0"
    if [ $COUNT -gt $DEFINE ];
          then
                  grep $i /usr/local/ddos/white.txt /dev/null
                  if [ $? -gt $ZERO ];
                  then
        IPEX=`iptables -nL | grep "$i"`
        if [ -z "$IPEX" ];
        then
                      echo "$COUNT $i"
                      iptables -I INPUT -s $i -j DROP
          echo -e "[`date "+%Y-%m-%d %T"`] IP: $i\tCOUNT: $COUNT" /usr/local/ddos/banned.log
        fi
                  fi
          fi
    ((cnt=cnt+1))
  fi
done
echo "[`date "+%Y-%m-%d %T"`] Script runned, found $cnt" > /usr/local/ddos/run.log
