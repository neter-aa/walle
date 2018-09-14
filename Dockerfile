FROM php:7.1.21-fpm-alpine
MAINTAINER liuchang@liebaodaikuan.com

RUN echo 'http://mirrors.aliyun.com/alpine/v3.7/community/'>/etc/apk/repositories &&  \
    echo 'http://mirrors.aliyun.com/alpine/v3.7/main/'>>/etc/apk/repositories && \
    apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    rm -rf /tmp/*

RUN apk update && apk upgrade && \
    apk add --no-cache bash ansible openssh git curl nginx freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev && \
    docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-configure mysqli --with-mysqli=mysqlnd && \
    docker-php-ext-install mysqli && \
    NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
    docker-php-ext-install -j${NPROC} gd && \
    apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

RUN sed -i -e 's/# Host/Host/' -e 's/#\s*StrictHostKeyChecking.*/StrictHostKeyChecking no/' /etc/ssh/ssh_config && \
    mkdir -p /var/log/nginx/ && mkdir -p /run/nginx && \
    mkdir -p /opt/data/www/walle-web && \
    cd /opt/data/www/walle-web     && \
    git clone https://github.com/meolu/walle-web.git . && \
    mkdir -p /usr/local/bin && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

RUN cd /opt/data/www/walle-web && \
    composer install --prefer-dist --no-dev --optimize-autoloader -vvvv && \
    mkdir -p /opt/data/www/walle-web/runtime/ansible_hosts && \
    mkdir -p /data/resource && \
    chown -R www-data.www-data /data /opt && \
    cp -r vendor/bower-asset vendor/bower && \
    su www-data -s /bin/sh -c 'ssh-keygen -q -N "" -f /home/www-data/.ssh/id_rsa'

#GlobalHelper bug cant cover utf-8 to utf-8//ingore
RUN sed -i -e '80s/text/out/' -e '81s/}/}else{/' -e '82s/$out/    $out/' -e '83s/^/        }/' \
    /opt/data/www/walle-web/components/GlobalHelper.php

COPY ./config /opt/data/www/walle-web/config
COPY ./walle.conf /etc/nginx/conf.d/walle.conf

# volume mappings
#VOLUME ./config /opt/data/www/walle-web/config

EXPOSE 80/tcp 9000/tcp

COPY docker-entrypoint.sh /entrypoint.sh

#ENTRYPOINT ["/opt/data/www/walle-web/yii walle/setup"]
ENTRYPOINT ["/entrypoint.sh"]
#CMD ["/opt/data/www/walle-web/yii walle/setup"]
