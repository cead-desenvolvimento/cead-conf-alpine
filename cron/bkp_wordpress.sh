#!/bin/sh
# /srv/cead-conf-alpine/cron/bkp_wordpress.sh

PATH=/usr/bin:/bin

# CONFIG
SRC="/srv/volumes/cead/wordpress"
BACKUP_ROOT="/media/truenas/backups/site-cead-wordpress"
BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d)"
BACKUP_FILE="$BACKUP_DIR/site-cead-wordpress-$(date +%H).tar"
LOG_FILE="$BACKUP_ROOT/backup-$(date +%Y%m%d).log"
RETENTION_DAYS=15

mkdir -p "$BACKUP_DIR"
echo "[Backup] $(date +'%F %T') Iniciando backup: $BACKUP_FILE" >> "$LOG_FILE"
tar -cf "$BACKUP_FILE" -C "$SRC" .
BACKUP_SIZE_BYTES=$(stat -c %s "$BACKUP_FILE" 2>/dev/null)
BACKUP_SIZE_MB=$(awk "BEGIN {mb=$BACKUP_SIZE_BYTES/1048576; printf \"%.2f\", mb}" | sed 's/\./,/')

echo "[Backup] $(date +'%F %T') Backup finalizado (${BACKUP_SIZE_MB}MB)." >> "$LOG_FILE"

echo "[Backup] $(date +'%F %T') Apagando backups com mais de $RETENTION_DAYS dias..." >> "$LOG_FILE"
find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \;
find "$BACKUP_ROOT" -maxdepth 1 -name "backup-*.log" -mtime +$RETENTION_DAYS -delete

echo "[Backup] $(date +'%F %T') Limpeza concluída." >> "$LOG_FILE"
