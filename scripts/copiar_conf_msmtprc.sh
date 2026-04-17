#!/bin/sh
# /srv/cead-conf-alpine/copiar_conf_msmtprc.sh

PATH=/usr/bin:/bin

if [ ! -f "/etc/msmtprc" ]; then
    cp /srv/cead-conf-alpine/msmtprc/msmtprc /etc/
fi
ln -sf /usr/bin/msmtp /usr/sbin/sendmail
