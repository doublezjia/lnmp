#!/bin/bash
# @Author  : zealous (doublezjia@163.com)
# @Link    : https://github.com/doublezjia
# centos7


nginxPackage="nginx-1.17.6.tar.gz"
nginxPackageFdir="nginx-1.17.6"
BeginDir=`pwd`
if [ $USER != "root" ]; then
    echo "Please use root account operation or sudo!"
    exit 1
fi
echo "Install the compilation environment"
yum update -y
yum install openssl openssl-devel zlib zlib-devel pcre pcre-devel gcc gcc-c++ make -y


if [ ! -f "./$nginxPackage" ]; then
    echo "Download NGINX"
    which wget 1>/dev/null 2>&1
    if [ `echo $?` == 1 ]; then
        echo "Install wget"
        yum install wget -y 
    fi
    wget http://nginx.org/download/$nginxPackage
    if [ `echo $?` == 1 ]; then
        echo "Downloads failed."
        exit 1
    fi    
fi

if [ `echo $?` == 0 ]; then
    echo "NEW user nginx"
    groupadd nginx
    useradd -g nginx -s /sbin/nologin nginx
    echo "Unzip $nginxPackage"
    tar xvf $nginxPackage
    cd ./$nginxPackageFdir

    echo "Configure nginx"
    ./configure --prefix=/usr/local/nginx \
    --sbin-path=/usr/local/nginx/sbin/nginx \
    --conf-path=/usr/local/nginx/conf/nginx.conf \
    --pid-path=/usr/local/nginx/var/run/nginx.pid \
    --lock-path=/var/lock/nginx.lock \
    --error-log-path=/usr/local/nginx/var/log/error.log \
    --http-log-path=/usr/local/nginx/var/log/access.log \
    --http-client-body-temp-path=/usr/local/nginx/var/tmp/client_temp \
    --http-proxy-temp-path=/usr/local/nginx/var/tmp/proxy_temp \
    --http-fastcgi-temp-path=/usr/local/nginx/var/tmp/fastcgi_temp \
    --http-uwsgi-temp-path=/usr/local/nginx/var/tmp/uwsgi_temp \
    --http-scgi-temp-path=/usr/local/nginx/var/tmp/scgi_temp \
    --user=nginx --group=nginx --with-http_ssl_module \
    --with-http_flv_module --with-http_gzip_static_module \
    --with-http_stub_status_module --with-pcre

    echo "Install nginx"
    make && make install
    if [ `echo $?` == 0 ]; then
        echo "Run nginx"
        if [ ! -d "/usr/local/nginx/var/tmp" ]; then
            mkdir /usr/local/nginx/var/tmp
        fi

        /usr/local/nginx/sbin/nginx
        if [ `echo $?` == 0 ]; then
            echo "Successfully."
            cd $BeginDir
            echo "Remove $nginxPackage"
            rm -rf ./$nginxPackage
            echo "Remove $nginxPackageFdir"
            rm -rf ./$nginxPackageFdir
        fi
    else
        echo "Installation failed"
        exit 1
    fi
fi



