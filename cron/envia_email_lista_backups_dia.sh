#!/bin/sh
# /srv/cead-conf-alpine/cron/envia_email_lista_backups_dia.sh

PATH=/usr/bin:/bin

# CONFIG
DATA=$(date -u -d "@$(($(date +%s) - 86400))" +%Y%m%d)
DESTINO="redes.cead@ufjf.br"
ASSUNTO="Relatório de backups - $DATA"
TMP=$(mktemp)

echo "Resumo diário de backups ($DATA)" > "$TMP"
echo "----------------------------------" >> "$TMP"

for LOG in \
    /media/truenas/backups/sistemascead-database/backup-$DATA.log \
    /media/truenas/backups/site-cead-database/backup-$DATA.log \
    /media/truenas/backups/site-cead-wordpress/backup-$DATA.log
do
    if [ -f "$LOG" ]; then
        echo >> "$TMP"
        echo "$(basename "$(dirname "$LOG")"):" >> "$TMP"
        grep -E "Iniciando backup|Backup finalizado" "$LOG" >> "$TMP"
    else
        echo >> "$TMP"
        echo "$(basename "$(dirname "$LOG")"):" >> "$TMP"
        echo "⚠️ Log não encontrado: $LOG" >> "$TMP"
    fi
done

echo >> "$TMP"
echo "----------------------------------" >> "$TMP"

mail -s "$ASSUNTO" "$DESTINO" < "$TMP"

rm -f "$TMP"
