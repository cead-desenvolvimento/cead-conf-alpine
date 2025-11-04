#!/bin/sh
# /srv/cead-conf-alpine/instalar_cron.sh

PATH=/usr/bin:/bin

# Linhas de cron — uma por linha
CRONLINES="
0 * * * * /srv/sistemascead-docker/database/backup.sh
5 * * * * /srv/site-docker/database/backup.sh
15 0 * * * find /media/ibm/cgco/moodle/ -type f -mtime +21 -delete
45 0 * * * /srv/cead-conf-alpine/cron/permissao_nas.sh
45 2 * * * /srv/cead-conf-alpine/cron/bkp_wordpress.sh
15 3 * * * /srv/cead-conf-alpine/cron/verifica_dump_moodle.sh
15 4 * * * /srv/cead-conf-alpine/cron/sincroniza_ibm.sh
15 5 * * * /srv/cead-conf-alpine/cron/verifica_integridade_moodle.sh
45 6 * * * /srv/cead-conf-alpine/cron/envia_email_lista_backups_dia.sh
45 6 * * * /srv/cead-conf-alpine/cron/verifica_storages.sh
15,45 7-18 * * 1-5 /usr/bin/docker exec sistemascead-backend python manage.py axes_reset
0 0 1 * * /usr/bin/docker exec sistemascead-backend python manage.py axes_purge_year
0 4 * * * /usr/bin/docker exec sistemascead-backend python manage.py frequencia_moodle --escondec10
"

for script in \
    /srv/cead-conf-alpine/cron/permissao_nas.sh \
    /srv/cead-conf-alpine/cron/bkp_wordpress.sh \
    /srv/cead-conf-alpine/cron/verifica_dump_moodle.sh \
    /srv/cead-conf-alpine/cron/sincroniza_ibm.sh \
    /srv/cead-conf-alpine/cron/verifica_integridade_moodle.sh \
    /srv/cead-conf-alpine/cron/envia_email_lista_backups_dia.sh \
    /srv/cead-conf-alpine/cron/verifica_storages.sh
do
    chmod +x "$script"
done

TMPFILE=$(mktemp)
crontab -l 2>/dev/null > "$TMPFILE"

echo "$CRONLINES" | while IFS= read -r line; do
    [ -z "$line" ] && continue
    grep -F "$line" "$TMPFILE" >/dev/null 2>&1 || echo "$line" >> "$TMPFILE"
done

crontab "$TMPFILE"
rm -f "$TMPFILE"
