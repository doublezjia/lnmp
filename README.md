# LNMP安装脚本

>环境：CentOS7+NGINX1.17+MySQL8+PHP7

CentOS7下安装NGINX1.17、MySQL8和PHP7,centos6未尝试运行。


### 文件说明
- nginx_setup.sh NGINX安装脚本
- mysql_setup.sh MySQL安装脚本
- php_setup.sh PHP安装脚本
- nginx NGINX启动文件 安装完NGINX后可以把文件复制到`/etc/init.d/`目录中并修改权限，然后就可以通过`/etc/init.d/nginx`来启动关闭nginx


要先安装NGINX和Mysql，最后在安装PHP

因为安装是使用编译安装的方法，安装前可以先通过网上下载安装包，放到脚本的同一目录下，然后运行脚本进行安装，不需要解压，如果没有下载安装包，脚本会自动通过wget进行下载程序安装包进行安装。

如果要修改安装包版本，只需修改脚本开头的`Package`这个压缩包的名字和`PackageFdir`这个解压后的文件夹名.

Mysql运行完会在脚本的最后显示mysql的初始密码，记得安装完后登陆mysql进行密码修改，如果不记得初始密码可以查看`/var/log/mysql.log`.

修改MySQL密码方法，登陆MySQL，然后执行如下命令
```
修改密码
use user;
alter user  'root'@'localhost' identified by 'your_password';

设置可以远程访问
update user set host = '%' where user = 'root';

刷新
flush privileges;
```


PHP安装完后，需要修改NGINX配置文件，把配置文件中PHP部分的注释去掉，并把`fastcgi_param`那一行的内容修改为`fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;`，然后重启NGINX

NGINX配置文件中PHP部分的配置:
```
        location ~ \.php$ {
            root           html;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
            include        fastcgi_params;
        }
```