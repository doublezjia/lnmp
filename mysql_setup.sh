#!/bin/bash
# @Author  : zealous (doublezjia@163.com)
# @Link    : https://github.com/doublezjia
# centos7 mysql8

mysqlPackage="mysql-8.0.17-linux-glibc2.12-x86_64.tar.xz"
mysqlPackageFdir="mysql-8.0.17-linux-glibc2.12-x86_64"

if [ $USER != "root" ]; then
    echo "Please use root account operation or sudo!"
    exit 1
fi


if [ ! -f "./$mysqlPackage" ]; then
    echo 'Downloads Mysql'
    which wget 1>/dev/null 2>&1
    if [ `echo $?` == 1 ]; then
        echo "Install wget"
        yum install wget -y 
    fi
    wget https://downloads.mysql.com/archives/get/file/$mysqlPackage
    if [ `echo $?` == 1 ]; then
        echo "Downloads failed."
        exit 1
    fi    
fi

# 检查是否存在mysql和mariadb库文件，存在就先删除
rpm -qa | grep mysql 1>/dev/null 2>&1
if [ `echo $?` == 0 ]; then
    rpm -e `rpm -qa | grep mysql` --nodeps
fi

rpm -qa | grep mariadb 1>/dev/null 2>&1
if [ `echo $?` == 0 ]; then
    rpm -e `rpm -qa | grep mariadb` --nodeps
fi


echo "NEW user mysql"
groupadd mysql
useradd -r -g mysql -s /sbin/nologin mysql

echo "Unzip $mysqlPackage"
mv ./$mysqlPackage /usr/local/
cd /usr/local/
tar xvf /usr/local/$mysqlPackage
if [ `echo $?` == 1 ]; then
    echo 'Unzip failed.'
    exit 1
else 
    mv /usr/local/$mysqlPackageFdir /usr/local/mysql
    chown -R mysql:mysql /usr/local/mysql
    echo "Remove $mysqlPackage"   
    rm -rf `pwd`/$mysqlPackage
fi


echo "Install Mysql"
/usr/local/mysql/bin/mysqld --initialize \
--user=mysql --basedir=/usr/local/mysql \
--datadir=/usr/local/mysql/data 1>/var/log/mysql.log 2>&1

if [ `echo $?` == 1 ]; then
    echo 'Installation failed.'
    exit 1
fi    

cat > /etc/my.cnf << EOF
[mysqld]
basedir=/usr/local/mysql
datadir=/usr/local/mysql/data
socket=/usr/local/mysql/mysql.sock
character-set-server=utf8
port=3306
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

[client]
socket=/usr/local/mysql/mysql.sock
default-character-set=utf8
EOF

cp -a /usr/local/mysql/support-files/mysql.server  /etc/init.d/mysqld

echo "Run Mysql"
/usr/local/mysql/bin/mysqld_safe --user=mysql & 
sleep 5
if [ `echo $?` == 0 ]; then
    /etc/init.d/mysqld restart
    # 设置开机启动
    chkconfig --level 35 mysqld on
fi

echo "Successfully."
mpwd=`cat /var/log/mysql.log | grep password | awk -F " " '{print $NF}'`
echo -e "Mysql Password is \033[0;32;40m$mpwd\033[0m"


