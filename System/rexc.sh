#!/bin/sh
if [ $# -ne 2 ] ; then
echo "Usage: $0 主机列表文件(all|qry|file)  命令(cmd)"
echo -e "\e[1;38m说 明: 参数1【all --hadoop集群所有主机|qry --查询服务器|file --自定义主机列表】\e[0m" 
echo -e "      \e[1;38m 参数2【start_qry --启动querysrv|stop_qry --停止querysrv|restart_qry --重启querysrv|cmd --其他系统命令】\e[0m" 
exit 0
fi

if [ $1 == all ] ; then
hosts=./pcserver_hosts.list.all
elif [ $1 == qry ] ; then
hosts=./pcserver_hosts.list.qry
else
hosts=$1
fi

if [ "$2" == start_qry ] ; then
#cmd="sh /home/cloud/platform/shell/start.sh;ps -ef | grep -v grep | grep querysrv"
cmd="sh /home/cloud/platform/shell/start.sh.jni;ps -ef | grep -v grep | grep querysrv"
elif [ "$2" == stop_qry ] ; then
cmd="sh /home/cloud/platform/shell/stop.sh;ps -ef | grep -v grep | grep querysrv"
elif [ "$2" == restart_qry ] ; then
cmd="sh /home/cloud/platform/shell/stop.sh ;sleep 1; ps -ef | grep -v grep | grep querysrv;sh /home/cloud/platform/shell/start.sh.jni;sleep 1;ps -ef | grep -v grep | grep querysrv"
elif [ "$2" == ps ] ; then
cmd="ps -ef | grep -v grep | grep querysrv"
else
cmd=$2
fi

echo -e "\e[1;38m*************************************\e[0m"
echo -e "\e[1;31m 主机列表文件 : $hosts \e[0m"
echo -e "\e[1;31m 将要执行命令 : $cmd \e[0m"
echo -e "\e[1;38m*************************************\e[0m"

echo "确认在每个节点执行上述命令(Y/N)?"
read insure
if [ "$insure" == Y ] ; then
echo -e "\e[1;38m命令执行中...\e[0m"
echo -e "\e[1;42m=====================================\e[0m"
#for node in `cat $hosts`
for node in `grep -v \# $hosts`
do
echo -e "\e[1;32m$node:\e[0m \c"
ssh  $node $cmd
#cd /mnt/disk1/platform_logs/query_logs/_hpb
#pwd
#ls -lrt hpb.log.20150821
#mv /mnt/disk1/platform_logs/query_logs/hpb.log.20150821 /mnt/disk1/platform_logs/query_logs/hpb.log.${node}.20150821
#ftp -n<<!
#open 172.16.0.31
#user root Beersheba!123
#binary
#lcd /mnt/disk1/platform_logs/query_logs
#cd /root/_hpb/_log/
#prompt
#mget hpb.log.$node.20150821
#close
#bye
#!
##这里增加ftp，实现跨机取数
done
else
echo "命令未执行，退出"
fi
