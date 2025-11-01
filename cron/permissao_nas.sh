#!/bin/sh
# /srv/cead-conf-alpine/cron/permissao_nas.sh

PATH=/usr/bin:/bin

find /media/truenas/proceg -type d -exec chmod 775 {} +
find /media/truenas/proceg -type f -exec chmod 664 {} +
chown -R 33:33 /cead/proceg
