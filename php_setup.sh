#!/bin/bash
# @Author  : zealous (doublezjia@163.com)
# @Link    : https://github.com/doublezjia
# centos7 php7

phpPackage="php-7.4.0.tar.gz"
phpPackageFdir="php-7.4.0"
beginDir=`pwd`

if [ $USER != "root" ]; then
    echo "Please use root account operation or sudo!"
    exit 1
fi

echo "Install the compilation environment"
yum makecache
yum -y install gcc gcc-c++ libxml2 libxml2-devel \
bzip2 bzip2-devel libmcrypt libmcrypt-devel \
openssl openssl-devel libcurl-devel libjpeg-devel \
libpng-devel freetype-devel readline readline-devel \
libxslt-devel perl perl-devel psmisc.x86_64 recode \
recode-devel libtidy libtidy-devel sqlite-devel oniguruma-devel

if [ `echo $?` == 1 ]; then
    echo "Install the compilation environment failed."
    exit 1
fi

if [ ! -f "./$phpPackage" ]; then
    echo "Download PHP"
    which wget 1>/dev/null 2>&1
    if [ `echo $?` == 1 ]; then
        echo "Install wget"
        yum install wget -y 
    fi
    wget https://www.php.net/distributions/$phpPackage
    if [ `echo $?` == 1 ]; then
        echo "Downloads failed."
        exit 1
    fi    
fi

echo "Unzip $phpPackage"
tar xvf $phpPackage
cd ./$phpPackageFdir

echo "Configure PHP"
 ./configure \
 --prefix=/usr/local/php7 \
 --sysconfdir=/usr/local/php7/conf \
 --with-config-file-path=/usr/local/php7/conf \
 --enable-fpm --with-mysqli=mysqlnd \
 --with-pdo-mysql=mysqlnd --with-mhash \
 --with-openssl --with-zlib --with-bz2 \
 --with-curl --with-libxml-dir --with-gd \
 --with-jpeg-dir --with-png-dir --with-zlib \
 --enable-mbstring --with-mcrypt --enable-sockets \
 --with-iconv-dir --with-xsl --enable-zip \
 --with-pcre-dir --with-pear --enable-session  \
 --enable-gd-native-ttf --enable-xml --with-freetype-dir \
 --enable-inline-optimization \
 --enable-shared --enable-bcmath --enable-sysvmsg \
 --enable-sysvsem --enable-sysvshm --enable-mbregex \
 --enable-pcntl --with-xmlrpc --with-gettext \
 --enable-exif --with-readline --with-recode --with-tidy

if [ `echo $?` == 1 ]; then
    echo "Configure PHP failed."
    exit 1
fi

echo "Install PHP."
make && make install

if [ `echo $?` == 1 ]; then
    echo "Install failed."
    exit 1
fi

cp `pwd`/php.ini-production /usr/local/php7/conf/php.ini
cp /usr/local/php7/conf/php-fpm.conf.default /usr/local/php7/conf/php-fpm.conf
cp /usr/local/php7/conf/php-fpm.d/www.conf.default /usr/local/php7/conf/php-fpm.d/www.conf
sed -i 's/user = nobody/user = nginx/' /usr/local/php7/conf/php-fpm.d/www.conf
sed -i 's/group = nobody/group = nginx/' /usr/local/php7/conf/php-fpm.d/www.conf
sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/' /usr/local/php7/conf/php-fpm.d/www.conf
sed -i 's/;pid = run\/php-fpm.pid/pid = run\/php-fpm.pid/' /usr/local/php7/conf/php-fpm.conf


cd $beginDir
echo "Remove $phpPackage"
rm -rf $beginDir/$phpPackage
echo "Remove $phpPackageFdir"
rm -rf $beginDir/$phpPackageFdir

echo "Start php-fpm."
/usr/local/php7/sbin/php-fpm
if [ `echo $?` == 1 ]; then
    echo "Run failed."
    exit 1
fi

echo "Stop php-fpm."    
killall -9 php-fpm

echo "configure php-fpm.service"
cat > /usr/lib/systemd/system/php-fpm.service << EOF
[Unit]
Description=php-fpm
After=syslog.target network.target

[Service]
Type=forking
PIDFile=/usr/local/php7/var/run/php-fpm.pid
ExecStart=/usr/local/php7/sbin/php-fpm
ExecReload=/bin/kill -USR2 \$MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

echo "Start php-fpm"
systemctl start php-fpm.service
echo "Enable php-fpm"
systemctl enable php-fpm.service

echo "Successfully."
