#!/bin/sh
# /srv/cead-conf-alpine/setup.sh

PATH=/usr/bin:/bin

echo ">>> [1/6] Configurando Docker..."
if sh scripts/copiar_conf_docker.sh; then
    echo "✔ Docker configurado"
else
    echo "⚠ Erro ao configurar docker"
    exit 1
fi

echo ">>> [2/6] Montando NFS..."
if sh scripts/montar_nfs.sh; then
    echo "✔ NFS montado"
else
    echo "⚠ Erro ao montar NFS"
    exit 1
fi

echo ">>> [3/6] Copiando configurações de logrotate..."
if sh scripts/copiar_conf_logrotate.sh; then
    echo "✔ Logrotate configurado"
else
    echo "⚠ Erro ao configurar logrotate"
    exit 1
fi

echo ">>> [4/6] Instalando tarefas de cron..."
if sh scripts/instalar_cron.sh; then
    echo "✔ Cron configurado"
else
    echo "⚠ Erro ao configurar cron"
    exit 1
fi

echo ">>> [5/6] Configurando Nginx..."
if sh scripts/copiar_conf_nginx.sh; then
    echo "✔ nginx configurado"
else
    echo "⚠ Erro ao configurar nginx"
    exit 1
fi

echo ">>> [5/6] Configurando msmtprc..."
if sh scripts/copiar_conf_msmtprc.sh; then
    echo "✔ msmtprc configurado"
else
    echo "⚠ Erro ao configurar msmtprc"
    exit 1
fi

echo "✔ Concluído"
