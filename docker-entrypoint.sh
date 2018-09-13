#!/bin/sh -xe
php-fpm &
nginx -g 'daemon off;'
#$@
