#!/bin/sh
# /srv/cead-conf-alpine/copiar_conf_nginx.sh

PATH=/usr/bin:/bin

rm -rf /etc/nginx/nginx.conf /etc/nginx/http.d
cp -r /srv/cead-conf-alpine/nginx/* /etc/nginx/
mkdir /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/sistemascead /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/cead /etc/nginx/sites-enabled/
mv /tmp/ssl /etc/nginx/

rc-service nginx restart
