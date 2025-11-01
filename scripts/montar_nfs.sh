#!/bin/sh
# /srv/cead-conf-alpine/montar_nfs.s

PATH=/usr/bin:/bin:/sbin

echo ">>> Montando truenas.cead.lan..."
mkdir -p /media/truenas
grep -q 'truenas.cead.lan' /etc/fstab || echo 'truenas.cead.lan:/mnt/cead /media/truenas nfs defaults,_netdev 0 0' >> /etc/fstab

echo ">>> Montando disco IBMCEAD..."
mkdir -p /media/ibm
UUID_IBM=$(blkid /dev/sdb1 | sed -n 's/.*UUID="\([^"]*\)".*/\1/p')
if [ -n "$UUID_IBM" ] && ! grep -q "$UUID_IBM" /etc/fstab; then
    echo "UUID=$UUID_IBM /media/ibm ext4 defaults,_netdev 0 0" >> /etc/fstab
fi

mount -a
