#!/bin/sh
# Author        : Adair
# Email         : adair0101@163.com
# Last modified : 2016-06-06 09:42
# Filename      : CentOS_youhua.sh
# Description   : 
 
#Source function library.
 
. /etc/init.d/functions
 
#date
DATE=`date +"%y-%m-%d %H:%M:%S"`
#ip
IPADDR=`grep "IPADDR" /etc/sysconfig/network-scripts/ifcfg-eth0|cut -d= -f 2 `
#hostname
HOSTNAME=`hostname -s`
#user
USER=`whoami`
#disk_check
DISK_SDA=`df -h |grep -w "/" |awk '{print $5}'`
#cpu_average_check
cpu_uptime=`cat /proc/loadavg|awk '{print $1,$2,$3}'`
  
#set LANG
export LANG=zh_CN.UTF-8
 
#Require root to run this script.
uid=`id | cut -d\( -f1 | cut -d= -f2`
if [ $uid -ne 0 ];then
  action "Please run this script as root." /bin/false
  exit 1
fi
#"stty erase ^H"
\cp /root/.bash_profile  /root/.bash_profile_$(date +%F)
erase=`grep -wx "stty erase ^H" /root/.bash_profile |wc -l`
if [ $erase -lt 1 ];then
    echo "stty erase ^H" >>/root/.bash_profile
    source /root/.bash_profile
fi
#Config Yum CentOS-Bases.repo
configYum(){
echo "================更新为国内YUM源=================="
  cd /etc/yum.repos.d/
 
  \cp CentOS-Base.repo CentOS-Base.repo.$(date +%F)
  ping -c 1 www.163.com>/dev/null
  if [ $? -eq 0 ];then
  wget http://mirrors.163.com/.help/CentOS6-Base-163.repo
  else
    echo "无法连接网络。"
    exit $?
  fi
  \cp CentOS-Base-163.repo CentOS-Base.repo
action "配置国内YUM完成"  /bin/true
echo "================================================="
echo ""
  sleep 2
}
#Charset zh_CN.UTF-8
initI18n(){
echo "================更改为中文字符集================="
  \cp /etc/sysconfig/i18n /etc/sysconfig/i18n.$(date +%F)
  echo "LANG="zh_CN.UTF-8"" >/etc/sysconfig/i18n
  source /etc/sysconfig/i18n
  echo '#cat /etc/sysconfig/i18n'
  grep LANG /etc/sysconfig/i18n
action "更改字符集zh_CN.UTF-8完成" /bin/true
echo "================================================="
echo ""
  sleep 2
}
#Close Selinux and Iptables
initFirewall(){
echo "============禁用SELINUX及关闭防火墙=============="
  \cp /etc/selinux/config /etc/selinux/config.$(date +%F)
  /etc/init.d/iptables stop
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  setenforce 0
  /etc/init.d/iptables status
  echo '#grep SELINUX=disabled /etc/selinux/config ' 
  grep SELINUX=disabled /etc/selinux/config 
  echo '#getenforce '
  getenforce 
action "禁用selinux及关闭防火墙完成" /bin/true
echo "================================================="
echo ""
  sleep 2
}
#Init Auto Startup Service
initService(){
echo "===============精简开机自启动===================="
  export LANG="en_US.UTF-8"
  for name in `chkconfig --list|grep 3:on|awk '{print $1}' |grep -Ev "sshd|network|rsyslog|crond|sysstat"`;do chkconfig $name off;done
  echo '+--------在三级别开着的服务---------+'
  chkconfig --list |grep 3:on
  echo '+----------------------------------+'
  export LANG="zh_CN.UTF-8"
action "精简开机自启动完成" /bin/true
echo "================================================="
echo ""
  sleep 2
}
#Change sshd default port and prohibit user root remote login.
initSsh(){
echo "========修改ssh默认端口禁用root远程登录=========="
  \cp /etc/ssh/sshd_config /etc/ssh/sshd_config.$(date +%F)
  sed -i 's/#Port 22/Port 51231/g' /etc/ssh/sshd_config
  sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
  sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
  sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
  sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
  echo '+-------modify the sshd_config-------+'
  echo 'Port 51231'
  echo 'PermitEmptyPasswords no'
  echo 'PermitRootLogin no'
  echo 'PasswordAuthentication no'
  echo 'UseDNS no'
  echo 'PubkeyAuthentication yes'
  echo '+------------------------------------+'
  /etc/init.d/sshd reload && action "修改ssh默认参数完成" /bin/true || action "修改ssh参数失败" /bin/false
echo "================================================="
echo ""
  sleep 2
}
#time sync
syncSysTime(){
echo "================配置时间同步====================="
  \cp /var/spool/cron/root /var/spool/cron/root.$(date +%F) 2>/dev/null
  NTPDATE=`grep ntpdate /var/spool/cron/root 2>/dev/null |wc -l`
  if [ $NTPDATE -eq 0 ];then
    echo "#times sync by lee at $(date +%F)" >>/var/spool/cron/root
    echo "*/5 * * * * /usr/sbin/ntpdate time.windows.com >/dev/null 2>&1" >> /var/spool/cron/root
  fi
  echo '#crontab -l'  
  crontab -l
action "配置时间同步完成" /bin/true
echo "================================================="
echo ""
  sleep 2
}
#install tools
initTools(){
  echo "#####install tools#####"
  yum groupinstall base -y
  yum groupinstall core -y
  yum groupinstall development libs -y
  yum groupinstall development tools -y
  echo "install toos complete."
  sleep 1
}
#add user and give sudoers
addUser(){
echo "===================新建用户======================"
#add user
while true
do  
    read -p "请输入新用户名:" name
    NAME=`awk -F':' '{print $1}' /etc/passwd|grep -wx $name 2>/dev/null|wc -l`
    if [ ${#name} -eq 0 ];then
       echo "用户名不能为空，请重新输入。"
       continue
    elif [ $NAME -eq 1 ];then
       echo "用户名已存在，请重新输入。"
       continue
    fi
useradd $name
break
done
#create password
while true
do
    read -p "为 $name 创建一个密码:" pass1
    if [ ${#pass1} -eq 0 ];then
       echo "密码不能为空，请重新输入。"
       continue
    fi
    read -p "请再次输入密码:" pass2
    if [ "$pass1" != "$pass2" ];then
       echo "两次密码输入不相同，请重新输入。"
       continue
    fi
echo "$pass2" |passwd --stdin $name
break
done
sleep 1
#add visudo
echo "#####add visudo#####"
\cp /etc/sudoers /etc/sudoers.$(date +%F)
SUDO=`grep -w "$name" /etc/sudoers |wc -l`
if [ $SUDO -eq 0 ];then
    #echo "$name  ALL=(ALL)       NOPASSWD: ALL" >>/etc/sudoers
    echo "$name  ALL=(ALL)       ALL" >>/etc/sudoers
    echo '#tail -1 /etc/sudoers'
    grep -w "$name" /etc/sudoers
    sleep 1
fi
action "创建用户$name并将其加入visudo完成"  /bin/true
echo "================================================="
echo ""
sleep 2
}
  
#Adjust the file descriptor(limits.conf)
initLimits(){
echo "===============加大文件描述符===================="
  LIMIT=`grep nofile /etc/security/limits.conf |grep -v "^#"|wc -l`
  if [ $LIMIT -eq 0 ];then
  \cp /etc/security/limits.conf /etc/security/limits.conf.$(date +%F)
  echo '*                  -        nofile         65535'>>/etc/security/limits.conf
  fi
  echo '#tail -1 /etc/security/limits.conf'
  tail -1 /etc/security/limits.conf
  ulimit -HSn 65535
  echo '#ulimit -n'
  ulimit -n
action "配置文件描述符为65535" /bin/true
echo "================================================="
echo ""
sleep 2
}
 
#Optimizing the system kernel
initSysctl(){
echo "================优化内核参数====================="
SYSCTL=`grep "net.ipv4.tcp" /etc/sysctl.conf |wc -l`
if [ $SYSCTL -lt 10 ];then
\cp /etc/sysctl.conf /etc/sysctl.conf.$(date +%F)
cat >>/etc/sysctl.conf<<EOF
net.ipv4.tcp_fin_timeout = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.ip_local_port_range = 4000 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 16384
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_max_orphans = 16384
net.netfilter.nf_conntrack_max = 25000000
net.netfilter.nf_conntrack_tcp_timeout_established = 180
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
EOF
fi
  \cp /etc/rc.local /etc/rc.local.$(date +%F)  
  modprobe nf_conntrack
  echo "modprobe nf_conntrack">> /etc/rc.local
  modprobe bridge
  echo "modprobe bridge">> /etc/rc.local
  sysctl -p  
action "内核调优完成" /bin/true
echo "================================================="
echo ""
  sleep 2
}
#menu2
menu2(){
while true
do
clear
cat << EOF
----------------------------------------
|****Please Enter Your Choice:[0-9]****|
----------------------------------------
(1) 新建一个用户并将其加入visudo
(2) 配置为国内YUM源镜像
(3) 配置中文字符集
(4) 禁用SELINUX及关闭防火墙
(5) 精简开机自启动
(6) 修改ssh默认端口及禁用root远程登录
(7) 设置时间同步
(8) 加大文件描述符
(9) 内核调优
(0) 返回上一级菜单
EOF
read -p "Please enter your Choice[0-9]: " input2
case "$input2" in
  0)
  clear
  break 
  ;;
  1)
  addUser
  ;;
  2)
  configYum
  ;;
  3)
  initI18n
  ;;
  4)
  initFirewall
  ;;
  5)
  initService
  ;;
  6)
  initSsh
  ;;
  7)
  syncSysTime
  ;;
  8)
  initLimits
  ;;
  9)
  initSysctl
  ;;
  *) echo "----------------------------------"
     echo "|          Warning!!!            |"
     echo "|   Please Enter Right Choice!   |"
     echo "----------------------------------"
     for i in `seq -w 3 -1 1`
       do 
         echo -ne "\b\b$i";
  sleep 1;
     done
     clear
esac
done
}
#initTools
#menu
while true
do
clear
echo "========================================"
echo '          Linux Optimization            '   
echo "========================================"
cat << EOF
|-----------System Infomation-----------
| DATE       :$DATE
| HOSTNAME   :$HOSTNAME
| USER       :$USER
| IP         :$IPADDR
| DISK_USED  :$DISK_SDA
| CPU_AVERAGE:$cpu_uptime
----------------------------------------
|****Please Enter Your Choice:[1-3]****|
----------------------------------------
(1) 一键优化
(2) 自定义优化
(3) 退出
EOF
#choice
read -p "Please enter your choice[0-3]: " input1
 
case "$input1" in
1) 
  addUser
  configYum
  initI18n
  initFirewall
  initService
  initSsh
  syncSysTime
  initLimits
  initSysctl
  ;;
  
2)
  menu2
  ;;
3) 
  clear 
  break
  ;;
*)   
  echo "----------------------------------"
  echo "|          Warning!!!            |"
  echo "|   Please Enter Right Choice!   |"
  echo "----------------------------------"
  for i in `seq -w 3 -1 1`
      do
        echo -ne "\b\b$i";
        sleep 1;
  done
  clear
esac  
done
