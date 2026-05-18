#!/bin/sh
# /srv/cead-conf-alpine/scripts/copiar_conf_local_docker.sh

PATH=/usr/bin:/bin

set -e

CONF_SRC="/srv/cead-conf-alpine/local.d/docker-nat.start"
CONF_DIR="/etc/local.d"
CONF_DEST="$CONF_DIR/docker-nat.start"

if [ ! -d "$CONF_DIR" ]; then
    mkdir -p "$CONF_DIR"
fi

if [ ! -f "$CONF_DEST" ] || ! cmp -s "$CONF_SRC" "$CONF_DEST"; then
    cp "$CONF_SRC" "$CONF_DEST"
    chmod +x "$CONF_DEST"
fi
