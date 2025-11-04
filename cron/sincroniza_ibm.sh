#!/bin/sh
# /srv/cead-conf-alpine/cron/sincroniza_ibm.sh

PATH=/usr/bin:/bin
EMAIL="redes.cead@ufjf.br"

# Verifica se o storage IBM está montado
if ! df -h | grep -q ibm; then
    echo "O storage IBM parece estar desmontado em $(date '+%d/%m/%Y %H:%M')" \
        | mail -s "⚠️ Storage IBM desmontado" "$EMAIL"
    exit 1
fi

# Função auxiliar de sincronização
sync_dir() {
    SRC="$1"
    DST="$2"
    DESC="$3"

    ERR=$(rsync -a --delete "$SRC" "$DST" 2>&1)
    STATUS=$?

    if [ $STATUS -ne 0 ]; then
        echo "❌ Erro ao sincronizar $DESC (código $STATUS)"
        echo "$ERR"
        return 1
    fi
    return 0
}

# Executa cópias e acumula mensagens de erro
ERRORS=""

OUT=$(sync_dir "/media/truenas/proceg/" "/media/ibm/proceg/" "Proceg")
[ $? -ne 0 ] && ERRORS="$ERRORS\n$OUT"

OUT=$(sync_dir "/media/truenas/backups/sistemascead-database/" "/media/ibm/backups/sistemascead-database/" "Banco SistemasCEAD")
[ $? -ne 0 ] && ERRORS="$ERRORS\n$OUT"

OUT=$(sync_dir "/media/truenas/backups/site-cead-database/" "/media/ibm/backups/site-cead-database/" "Banco Site-CEAD")
[ $? -ne 0 ] && ERRORS="$ERRORS\n$OUT"

OUT=$(sync_dir "/media/truenas/backups/site-cead-wordpress/" "/media/ibm/backups/site-cead-wordpress/" "WordPress Site-CEAD")
[ $? -ne 0 ] && ERRORS="$ERRORS\n$OUT"

if [ -n "$ERRORS" ]; then
    printf "⚠️ Erros detectados no backup IBM em %s:\n\n%s\n" \
        "$(date '+%d/%m/%Y %H:%M')" "$ERRORS" \
        | mail -s "⚠️ Erros no backup IBM ($(date +%d/%m/%Y))" "$EMAIL"
fi
