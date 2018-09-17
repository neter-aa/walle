# walle

walle+nginx

镜像大小：325MB
官网：https://github.com/meolu/walle-web
使用php:7.1.21-fpm-alpine作为基础镜像,添加了nginx。

dockerfile 包含bash ansible nginx ssh git php-fpm

build
```
docker build -t walle:latest .
```

run, 8080(宿主机）to 80(docker)
```
docker run --name walle -p 8080:80 -d walle
```

walle的数据库配置文件在config/local.php
初始化mysql
```
docker exec -it walle /bin/ash
cd /opt/data/www/walle-web
./yii walle/setup
```

查看rsa public key
```
docker exec walle cat /home/www-data/.ssh/id_rsa.pub
```

log dirs
```
/tmp/walle/
/opt/data/www/walle-web/runtime/logs/
```
