#!/bin/sh
# garante_montagens.sh
#
# FINALIDADE:
# Verificar periodicamente as montagens do TrueNAS e IBM Storwize
# e tentar recupera-las apos quedas de energia ou indisponibilidade.
#
# AMBIENTE:
# TrueNAS: compartilhamento NFS montado em /media/truenas.
# IBM Storwize V3700: volume iSCSI montado em /media/ibm.
#
# CUIDADOS:
# Este servidor executa backups importantes.
# Nao desmontar volumes nem reiniciar sessoes iSCSI automaticamente.
# O script apenas FAZ LOGIN nos nos iSCSI sem sessao; nunca faz logout.
# Nao alterar o UUID, os caminhos ou o /etc/fstab sem verificar.
# O IBM possui duas controladoras redundantes, mas o multipath
# ainda nao esta configurado no Linux.
#
# MANUTENCAO:
# Verificar os registros em /var/log/garante_montagens.log.
# O script utiliza flock para evitar execucoes simultaneas.
# Em caso de duvida, consultar o responsavel pela infraestrutura.
#
# IMPORTANTE:
# Nao executar testes de desmontagem em ambiente de producao.

PATH=/usr/sbin:/usr/bin:/sbin:/bin

LOG="/var/log/garante_montagens.log"

# Impede duas execucoes simultaneas
exec 9>/run/garante_montagens.lock
if ! flock -n 9; then
    exit 0
fi

# Registra eventos no log
registrar() {
    echo "$(date '+%d/%m/%Y %H:%M:%S') - $1" >> "$LOG"
}

# Nos iSCSI do IBM (iqn,ip do portal)
IBM_NOS="iqn.1986-03.com.ibm:2145.ibmcead.node1,172.16.100.50
iqn.1986-03.com.ibm:2145.ibmcead.node2,172.16.100.51"

# Garante sessao iSCSI com cada no do IBM.
# Apenas faz login nos nos sem sessao; nunca faz logout nem reinicia sessao.
garantir_sessao_iscsi() {
    SESSOES=$(timeout -s TERM -k 5 15 iscsiadm -m session 2>/dev/null)

    echo "$IBM_NOS" | while IFS=, read -r iqn ip; do
        if echo "$SESSOES" | grep -F "$ip" | grep -Fq "$iqn"; then
            continue
        fi
        if ! nc -z -w 3 "$ip" 3260 >/dev/null 2>&1; then
            registrar "IBM: portal iSCSI $ip indisponivel."
            continue
        fi
        registrar "IBM: sem sessao com $iqn ($ip). Tentando login."
        if timeout -s TERM -k 5 30 iscsiadm -m node -T "$iqn" -p "$ip" --login >/dev/null 2>&1; then
            registrar "IBM: login iSCSI em $ip realizado."
        else
            registrar "ALERTA: login iSCSI em $ip falhou."
        fi
    done

    # Da tempo ao udev de criar os links em /dev/disk/by-id
    udevadm settle --timeout=10 >/dev/null 2>&1
}

# Verifica se o compartilhamento correto do TrueNAS esta montado
NFS_ATUAL=$(findmnt -n -o SOURCE,FSTYPE --mountpoint /media/truenas)

if [ "$NFS_ATUAL" = "truenas.cead.lan:/mnt/cead/cead nfs4" ]; then
    :
    # echo "TrueNAS: montagem correta. Nenhuma acao necessaria."
elif [ -n "$NFS_ATUAL" ]; then
    registrar "ALERTA: montagem inesperada em /media/truenas. Nenhuma acao executada."
else
    # Confere se a porta NFS responde antes de tentar montar
    if ! nc -z -w 3 172.16.100.90 2049 >/dev/null 2>&1; then
        registrar "TrueNAS: porta NFS indisponivel. Aguardando proxima tentativa."
    else
        registrar "TrueNAS: porta NFS acessivel. Tentando montar."

        if timeout -s TERM -k 5 30 mount /media/truenas; then
            NFS_DEPOIS=$(findmnt -n -o SOURCE,FSTYPE --mountpoint /media/truenas)

            if [ "$NFS_DEPOIS" = "truenas.cead.lan:/mnt/cead/cead nfs4" ]; then
                registrar "TrueNAS: montagem recuperada com sucesso."
            else
                registrar "ALERTA: comando terminou, mas a montagem correta nao foi confirmada."
            fi
        else
            registrar "ALERTA: tentativa de montagem do TrueNAS falhou."
        fi
    fi
fi

# Verifica se o volume correto do IBM esta montado
IBM_UUID="9a198f41-71cf-47a0-92dc-53dfc6461497"
IBM_ATUAL=$(findmnt -n -o UUID,FSTYPE --mountpoint /media/ibm)

if [ "$IBM_ATUAL" = "$IBM_UUID ext4" ]; then
    :
    # echo "IBM: montagem correta. Nenhuma acao necessaria."
elif [ -n "$IBM_ATUAL" ]; then
    registrar "ALERTA: montagem inesperada em /media/ibm. Nenhuma acao executada."
else
    IBM_DISPOSITIVO="/dev/disk/by-id/wwn-0x600507630082083c280000000000000f-part1"

    # Sem o dispositivo, tenta restabelecer as sessoes iSCSI (somente login)
    if [ ! -b "$IBM_DISPOSITIVO" ]; then
        garantir_sessao_iscsi
    fi

    if [ ! -b "$IBM_DISPOSITIVO" ]; then
        registrar "IBM: dispositivo indisponivel. Aguardando proxima tentativa."
    elif [ "$(blkid -s UUID -o value "$IBM_DISPOSITIVO")" != "$IBM_UUID" ]; then
        registrar "ALERTA: UUID do dispositivo IBM inesperado. Nenhuma acao executada."
    elif findmnt -rn -o UUID | grep -Fxq "$IBM_UUID"; then
        registrar "ALERTA: volume IBM ja montado em outro local. Nenhuma acao executada."
    else
        registrar "IBM: tentando recuperar montagem."

        if timeout -s TERM -k 5 30 mount -t ext4 "$IBM_DISPOSITIVO" /media/ibm; then
            IBM_DEPOIS=$(findmnt -n -o UUID,FSTYPE --mountpoint /media/ibm)

            if [ "$IBM_DEPOIS" = "$IBM_UUID ext4" ]; then
                registrar "IBM: montagem recuperada com sucesso."
            else
                registrar "ALERTA: montagem IBM nao confirmada."
            fi
        else
            registrar "ALERTA: tentativa de montagem IBM falhou."
        fi
    fi
fi
