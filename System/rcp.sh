#!/bin/sh
if [ $# -ne 3 ] ; then
echo "Usage: $0 �ļ� �����б��ļ� Ŀ��Ŀ¼"
exit 0
fi

echo -e "\e[1;38m*************************************\e[0m"
echo -e "\e[1;31m �����б��ļ� : $2 \e[0m"
echo -e "\e[1;31m ��Ҫ�ַ��ļ� : $1 to NODE:$3 \e[0m"
echo -e "\e[1;38m*************************************\e[0m"

echo "ȷ�Ϸַ��ļ������нڵ�(Y/N)?"
read insure
if [ "$insure" == Y ] ; then
echo -e "\e[1;38m����ִ����...\e[0m"
echo -e "\e[1;42m=====================================\e[0m"
grep -v ^\# $2|while read LINE
do
echo -e "\e[1;32mscp -r $1 $LINE:$3 \e[0m"
scp -r $1 $LINE:$3
done
else
echo "����δִ�У��˳�"
fi

#while read LINE
#do
#echo $LINE
##scp -r $1 $LINE:$3
##if [ "$LINE" == "^\#.*" ] ; then
#echo "scp -r $1 $LINE:$3"
##fi
#done< $2
