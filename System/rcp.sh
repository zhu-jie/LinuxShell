#!/bin/sh
if [ $# -ne 3 ] ; then
echo "Usage: $0 文件 主机列表文件 目标目录"
exit 0
fi

echo -e "\e[1;38m*************************************\e[0m"
echo -e "\e[1;31m 主机列表文件 : $2 \e[0m"
echo -e "\e[1;31m 将要分发文件 : $1 to NODE:$3 \e[0m"
echo -e "\e[1;38m*************************************\e[0m"

echo "确认分发文件至所有节点(Y/N)?"
read insure
if [ "$insure" == Y ] ; then
echo -e "\e[1;38m命令执行中...\e[0m"
echo -e "\e[1;42m=====================================\e[0m"
grep -v ^\# $2|while read LINE
do
echo -e "\e[1;32mscp -r $1 $LINE:$3 \e[0m"
scp -r $1 $LINE:$3
done
else
echo "命令未执行，退出"
fi

#while read LINE
#do
#echo $LINE
##scp -r $1 $LINE:$3
##if [ "$LINE" == "^\#.*" ] ; then
#echo "scp -r $1 $LINE:$3"
##fi
#done< $2
