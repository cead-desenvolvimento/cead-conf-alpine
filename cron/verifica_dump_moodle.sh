#!/usr/bin/env sh

ontem=$(date -u -d "@$(($(date +%s) - 86400))" +%Y%m%d)
hoje=$(date +%Y%m%d)

verifica_integridade_dump() {
	tar -xf /media/ibm/cgco/moodle/banco3.moodle.$hoje.tar.gz -C /media/ibm/cgco/moodle/

	if [ $? -ne 0 ]; then
		echo "ERRO: Dump nao encontrado ou nao descompactado corretamente" >> email_dump_moodle.txt
		return 1
	fi
	head -n 1 /media/ibm/cgco/moodle/backup/moodledb_temp/moodle.sql >> email_dump_moodle.txt
	if [ $? -ne 0 ]; then
		echo "ERRO: Problema ao obter a primeira linha do arquivo" >> email_dump_moodle.txt
		return 1
	fi
	head -n 1 /media/ibm/cgco/moodle/backup/moodledb_temp/moodle.sql | grep "MariaDB dump"
	if [ $? -ne 0 ]; then
		echo "ERRO: Primeira linha do dump parece inconsistente" >> email_dump_moodle.txt
		return 1
	fi
	echo "... dump ..." >> email_dump_moodle.txt
	tail -n 1 /media/ibm/cgco/moodle/backup/moodledb_temp/moodle.sql >> email_dump_moodle.txt
	if [ $? -ne 0 ]; then
		echo "ERRO: Problema ao obter a ultima linha do arquivo" >> email_dump_moodle.txt
		return 1
	fi
	tail -n 1 /media/ibm/cgco/moodle/backup/moodledb_temp/moodle.sql | grep "Dump completed"
	if [ $? -ne 0 ]; then
		echo "ERRO: Ultima linha do dump parece inconsistente" >> email_dump_moodle.txt
		return 1
    	fi
}

verifica_tamanho_dump() {
    tamanho_dump_descompactado=$(stat -c %s /media/ibm/cgco/moodle/backup/moodledb_temp/moodle.sql)
    gzip /media/ibm/cgco/moodle/backup/moodledb_temp/moodle.sql
    if [ $? -ne 0 ]; then
        echo "ERRO: Recompactacao do dump" >> email_dump_moodle.txt
        return 1
    fi
    mv /media/ibm/cgco/moodle/backup/moodledb_temp/moodle.sql.gz /media/ibm/cgco/moodle/banco3.moodle.$hoje.sql.gz
    chown cgco:users /media/ibm/cgco/moodle/banco3.moodle.$hoje.sql.gz
    rm -f /media/ibm/cgco/moodle/banco3.moodle.$hoje.tar.gz
    rm -rf /media/ibm/cgco/moodle/backup

    tamanho_dump_compactado_ontem=$(stat -c %s /media/ibm/cgco/moodle/banco3.moodle.$ontem.sql.gz 2>/dev/null || echo 0)
    tamanho_dump_compactado=$(stat -c %s /media/ibm/cgco/moodle/banco3.moodle.$hoje.sql.gz)

    if [ "$tamanho_dump_compactado_ontem" -gt 0 ]; then
        diferenca=$(( (tamanho_dump_compactado - tamanho_dump_compactado_ontem) * 100 / tamanho_dump_compactado_ontem ))
        if [ "${diferenca#-}" -gt 10 ]; then
            echo "ERRO: Tamanho do dump atual varia mais de 10% em relacao a ontem." >> email_dump_moodle.txt
        fi
    fi

    echo '-----------------------------' >> email_dump_moodle.txt
    echo "/media/ibm/cgco/moodle/banco3.moodle.$hoje.sql.gz" >> email_dump_moodle.txt
    echo "Tamanho do dump compactado: $(($tamanho_dump_compactado/1048576))MB" >> email_dump_moodle.txt
    echo "Tamanho do dump descompactado: $(($tamanho_dump_descompactado/1048576))MB" >> email_dump_moodle.txt
}

[ -f email_dump_moodle.txt ] && rm email_dump_moodle.txt
verifica_integridade_dump
verifica_tamanho_dump
cat email_dump_moodle.txt | grep "ERRO:"
if [ $? -eq 0 ]; then
	cat email_dump_moodle.txt | mail -s "Moodle - problema no dump da base de dados" redes.cead@ufjf.br
fi
[ -f email_dump_moodle.txt ] && rm email_dump_moodle.txt
