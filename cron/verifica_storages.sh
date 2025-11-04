#!/bin/sh
# /srv/cead-conf-alpine/cron/verifica_storages.sh

PATH=/usr/bin:/bin

ping -c1 truenas.cead.lan
[ $? -eq 0 ] || echo '' | mail -s "truenas.cead.lan offline" redes.cead@ufjf.br
ping -c1 ibm.cead.lan
[ $? -eq 0 ] || echo '' | mail -s "ibm.cead.lan offline" redes.cead@ufjf.br
