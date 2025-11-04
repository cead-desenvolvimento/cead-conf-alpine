#!/bin/sh
# /srv/cead-conf-alpine/copiar_conf_docker.sh

PATH=/usr/bin:/bin

set -e  # encerra o script se ocorrer algum erro

CONF_SRC="/srv/cead-conf-alpine/docker/daemon.json"
CONF_DIR="/etc/docker"
CONF_DEST="$CONF_DIR/daemon.json"

# Cria o diretório se não existir
if [ ! -d "$CONF_DIR" ]; then
    mkdir -p "$CONF_DIR"
fi

# Copia apenas se for diferente do destino
if [ ! -f "$CONF_DEST" ] || ! cmp -s "$CONF_SRC" "$CONF_DEST"; then
    cp "$CONF_SRC" "$CONF_DEST"
fi
