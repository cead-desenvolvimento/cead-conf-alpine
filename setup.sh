#!/bin/sh
# /srv/cead-conf-alpine/setup.sh

PATH=/usr/bin:/bin

echo ">>> [1/9] Configurando Docker..."
if sh scripts/copiar_conf_docker.sh; then
    echo "✔ Docker configurado"
else
    echo "⚠ Erro ao configurar docker"
    exit 1
fi

echo ">>> [2/9] Montando NFS..."
if sh scripts/montar_nfs.sh; then
    echo "✔ NFS montado"
else
    echo "⚠ Erro ao montar NFS"
    exit 1
fi

echo ">>> [3/9] Copiando configurações de logrotate..."
if sh scripts/copiar_conf_logrotate.sh; then
    echo "✔ Logrotate configurado"
else
    echo "⚠ Erro ao configurar logrotate"
    exit 1
fi

echo ">>> [4/9] Instalando tarefas de cron..."
if sh scripts/instalar_cron.sh; then
    echo "✔ Cron configurado"
else
    echo "⚠ Erro ao configurar cron"
    exit 1
fi

echo ">>> [5/9] Configurando Nginx..."
if sh scripts/copiar_conf_nginx.sh; then
    echo "✔ nginx configurado"
else
    echo "⚠ Erro ao configurar nginx"
    exit 1
fi

echo ">>> [6/9] Configurando fail2ban..."
if sh scripts/copiar_conf_fail2ban.sh; then
    echo "✔ fail2ban configurado"
else
    echo "⚠ Erro ao configurar fail2ban"
    exit 1
fi

echo ">>> [7/9] Configurando msmtprc..."
if sh scripts/copiar_conf_msmtprc.sh; then
    echo "✔ msmtprc configurado"
else
    echo "⚠ Erro ao configurar msmtprc"
    exit 1
fi

echo ">>> [8/9] Configurando regras nftables para Docker..."
if sh scripts/copiar_conf_nftables_docker.sh; then
    echo "✔ nftables Docker configurado"
else
    echo "⚠ Erro ao configurar nftables Docker"
    exit 1
fi

echo ">>> [9/9] Configurando NAT Docker no boot..."
if sh scripts/copiar_conf_local_docker.sh; then
    echo "✔ docker-nat.start configurado"
else
    echo "⚠ Erro ao configurar docker-nat.start"
    exit 1
fi

echo "✔ Concluído"
