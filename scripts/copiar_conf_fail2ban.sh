#!/bin/sh
# /srv/cead-conf-alpine/copiar_conf_fail2ban.sh

PATH=/usr/bin:/bin

if [ ! -f "/etc/fail2ban" ]; then
    cp /srv/cead-conf-alpine/fail2ban/jail.local /etc/fail2ban/
    cp /srv/cead-conf-alpine/fail2ban/action.d/*.conf /etc/fail2ban/action.d/
    cp /srv/cead-conf-alpine/fail2ban/filter.d/*.conf /etc/fail2ban/filter.d/
    cp /srv/cead-conf-alpine/fail2ban/nftables.nft /etc/
fi
