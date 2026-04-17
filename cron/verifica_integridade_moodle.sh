#!/bin/sh
# /srv/cead-conf-alpine/cron/verifica_integridade_moodle.sh

PATH=/usr/bin:/bin

# CONFIG
BACKUP_DIR="/media/ibm/cgco/moodle"
EMAIL="redes.cead@ufjf.br"
DATA_HOJE=$(date +%Y-%m-%d)
DATA_EXIBICAO=$(date +%d-%m-%Y)
ARQUIVO_RELATORIO="/tmp/moodle_integridade.txt"

testar_backup() {
    arquivo="$1"
    tar -tf "$arquivo" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ $(basename "$arquivo") está íntegro. Tamanho: $(du -h "$arquivo" | awk '{print $1}')" >> "$ARQUIVO_RELATORIO"
    else
        echo "❌ ERRO: $(basename "$arquivo") está corrompido ou incompleto!" >> "$ARQUIVO_RELATORIO"
    fi
}

echo "Relatório de integridade dos backups Moodle - $DATA_EXIBICAO" > "$ARQUIVO_RELATORIO"
echo "------------------------------------------------------------" >> "$ARQUIVO_RELATORIO"

FULL_FILE=$(ls "$BACKUP_DIR"/moodle3."$DATA_HOJE"_FULL_*.tar 2>/dev/null | head -n 1)
INC_FILE=$(ls "$BACKUP_DIR"/moodle3."$DATA_HOJE"_INC_*.tar 2>/dev/null | head -n 1)

if [ -n "$FULL_FILE" ]; then
    testar_backup "$FULL_FILE"
elif [ -n "$INC_FILE" ]; then
    testar_backup "$INC_FILE"
else
    echo "❌ Nenhum backup encontrado para $DATA_EXIBICAO em $BACKUP_DIR" >> "$ARQUIVO_RELATORIO"
fi

mail -s "Integridade do Backup do dia - $DATA_EXIBICAO" "$EMAIL" < "$ARQUIVO_RELATORIO"
rm -f "$ARQUIVO_RELATORIO"
