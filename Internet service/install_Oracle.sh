#!/bin/bash
#author:Jie
#Email:0101adair@gmail.com
##修改主机名##
sed -i "s/HOSTNAME=localhost.localdomain/HOSTNAME=oracledb/"  /etc/sysconfig/network
hostname oracledb
##添加主机与IP对应记录##
echo '192.168.10.123 oracledb' >> /etc/hosts
##关闭Selinux##
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
setenforce 0
#yum install -y binutils compat-libstdc++-33 compat-libstdc++ elfutils-libelf elfutils-libelf-devel gcc gcc-c++ glibc glibc glibc-common glibc-devel glibc-devel glibc-headers ksh libaio libaio libaio-devel libaio-devel libgcc libgcc libstdc++ libstdc++ libstdc++-devel make sysstat unixODBC unixODBC unixODBC-devel unixODBC-devel
yum install binutils compat-libstdc++-33 elfutils elfutils-libelf-devel gcc gcc-c++ glibc glibc-common glibc-devel glibc-headers libaio libaio-devel libgcc libstdc++ libstdc++-devel make sysstat unixODBC unixODBC-devel  
#特殊说明：pdksh-5.2.14-37.el5.x86_64.rpm ：此安装包yum源中没有，但必须，可通过其他方式下载后手工安装；
rpm -qa |grep ksh |xargs -e --nodeps &>/dev/null
cd /opt/software
rpm -i pdksh-5.2.14-37.el5_8.1.x86_64.rpm &>/dev/null
#### 创建必需的用户、组账号 ###############################
grep oinstall /etc/group &> /dev/null || groupadd  oinstall
grep dba /etc/group &> /dev/null || groupadd  dba
grep oracle /etc/passwd &> /dev/null || useradd -g oinstall -G dba oracle
echo "pwd123" | passwd --stdin oracle &> /dev/null
####创建数据库安装目录 ##################################
mkdir -p /opt/oracle
chown -R oracle:oinstall /opt/oracle
chmod -R 775 /opt/oracle
#### 调整内核运行参数 ####################################
modprobe bridge &>/dev/null
lsmod|grep bridge  &>/dev/null
grep io-max-nr /etc/sysctl.conf &> /dev/null || echo 'fs.aio-max-nr = 1048576
fs.file-max = 6815744
#kernel.shmall = 2097152
#kernel.shmmax = 536870912
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048586' >> /etc/sysctl.conf
sysctl -p &> /dev/null
##注意执行是如果出现
#error: "net.bridge.bridge-nf-call-ip6tables" is an unknown key
#error: "net.bridge.bridge-nf-call-iptables" is an unknown key
#error: "net.bridge.bridge-nf-call-arptables" is an unknown ke
#解决办法
#modprobe bridge
#lsmod|grep bridge
#### 调整用户会话限制 ####################################
grep oracle /etc/security/limits.conf &> /dev/null || echo 'oracle           soft    nproc   2047
oracle           hard    nproc   16384
oracle           soft    nofile  1024
oracle           hard    nofile  65536' >> /etc/security/limits.conf
grep pam_limits.so /etc/pam.d/login &> /dev/null || echo 'session    required     pam_limits.so' >> /etc/pam.d/login
grep oracle /etc/profile &> /dev/null || echo 'if [ $USER = "oracle" ]; then
    ulimit -u 16384 -n 65536
fi' >> /etc/profile
#### 配置Oracle用户环境 ##################################
grep ORACLE ~oracle/.bash_profile &> /dev/null || echo "umask 022
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=/opt/oracle/product/11.2/db_1
export ORACLE_SID=orcl
export LANG=zh_CN.UTF-8
export NLS_LANG="AMERICAN_AMERICA".AL32UTF8
export PATH=/opt/oracle/product/11.2/db_1/bin/:$PATH
export DISPLAY=:0.0" >> ~oracle/.bash_profile

####解压并安装####################################################
#unzip solaris.sparc64_12cR1_database_1of2.zip 
#unzip solaris.sparc64_12cR1_database_2of2.zip 
#xhost +
#su - oracle
#cd database
#./runInstall
