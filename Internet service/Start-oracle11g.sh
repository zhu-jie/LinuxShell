#!/bin/bash
#chkconfig: 345 99 10
#description: Startup Script for Oracle Databases
#author:Jie
#Email:0101adair@gmail.com
#/etc/init.d/oracle11g
#要成功启动数据库实例还得打开Oracle设置的一个关卡：vi /etc/oratab

#orcl:/opt/oracle/product/11.2/db_1:Y#默认为orcl:/opt/oracle/product/11.2/db_1:N
#修改dbstart,dbshut
#cd $ORACLE_HOME/bin;vi dbstart
#找到 ORACLE_HOME_LISTNER=$1  这行， 修改成: ORACLE_HOME_LISTNER=$ORACLE_HOME 修改dbshut内容跟上面一样
#添加开机启动项
# chkconfig --add oracle11g
# chkconfig oracle11g on
# chkconfig --list oracle11g
export ORACLE_SID=orcl
#export ORACLE_HOME_LISTNER=/apps/oracle/product/11.2.0.1/db_1/bin/
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=/opt/oracle/product/11.2/db_1
export PATH=$PATH:$ORACLE_HOME/bin
case "$1" in
start)
su oracle -c $ORACLE_HOME/bin/emctl start dbconsole &>/dev/null
su oracle -c $ORACLE_HOME/bin/dbstart
touch /var/lock/oracle
echo "OK"
;;
stop)
echo -n "Shutdown Oracle: "
su oracle -c $ORACLE_HOME/bin/emctl stop dbconsole &>/dev/null
su oracle -c $ORACLE_HOME/bin/dbshut 
rm -f /var/lock/oracle
echo "OK"
;;
*)
echo "Usage: 'basename $0' start|stop"
exit 1
esac
exit 0

