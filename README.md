## O que tem neste repositório?

- Configuração para um _host_ Alpine GNU/Linux, que prepara o ambiente para a execução do _site_ e sistema do CEAD
- Clonar em `/srv` para compatibilidade dos _scripts_

## Instalação GNU/Linux Alpine

- **No R900**, antes de iniciar a instalação, carregue o módulo megaraid_sas: `modprobe megaraid_sas`, e;
- Antes de reiniciar pelo instalador, Coloque a _string_ `megaraid_sas` em `/etc/modules`, e;
- Atualize o `initramfs` e o `extlinux.conf` com o comando `update-kernel`, e;
- Execute `update-extlinux`, `dd if=/usr/share/syslinux/mbr.bin of=/dev/sda`, `sync`
- Então reinicie.

## Atualização do kernel

Se o kernel atualizar, é preciso carregar o megaraid_sas na nova versão. Suponha que a nova versão seja 6.12.69-0-lts

- Verifique se a _string_ `scsi` está em `/etc/mkinitfs/mkinitfs.conf`

```bash
torresmo:~# cat /etc/mkinitfs/mkinitfs.conf
features="ata base ide scsi usb virtio ext4"
```

- Então rode

```bash
mkinitfs -c /etc/mkinitfs/mkinitfs.conf -b / -k 6.12.69-0-lts -o /boot/initramfs-lts
```

- Confira se vai carregar (o comando precisa retornar não vazio)

```bash
torresmo:~# zcat /boot/initramfs-lts | cpio -it | grep megaraid
lib/modules/6.12.69-0-lts/kernel/drivers/scsi/megaraid
lib/modules/6.12.69-0-lts/kernel/drivers/scsi/megaraid.ko.gz
lib/modules/6.12.69-0-lts/kernel/drivers/scsi/megaraid/megaraid_mbox.ko.gz
lib/modules/6.12.69-0-lts/kernel/drivers/scsi/megaraid/megaraid_mm.ko.gz
lib/modules/6.12.69-0-lts/kernel/drivers/scsi/megaraid/megaraid_sas.ko.gz
46048 blocks
```

- Atualizar `/boot/extlinux.conf` (colocar `megaraid_sas` no fim da linha dos módulos)

```text
APPEND root=UUID=b9b68c43-4e83-424f-b8a1-1326116da824 modules=sd-mod,usb-storage,ext4,megaraid_sas quiet rootfstype=ext4
```

- Pode reiniciar depois de sincronizar o disco

## Instalação dos pacotes necessários

Depois de instalar o GNU/Linux Alpine, descomente a linha com `community` em `/etc/apk/repositories`

```bash
vi /etc/apk/repositories
```

Atualize e baixe os pacotes necessários

```bash
apk update
apk add ca-certificates docker docker-compose fail2ban git libmaxminddb logrotate mailx msmtp nftables nfs-utils nginx nginx-mod-http-geoip2 open-iscsi rsync tar util-linux
update-ca-certificates
rc-update add docker boot
rc-update add fail2ban default
rc-update add nginx default
rc-update add iscsid default
rc-update add netmount default
rc-update add nfsmount default
rc-service docker start
rc-service iscsid start
```

Configure o IBM (172.16.100.40) para ser mapeado no _host_

- Verifique o arquivo `/etc/iscsi/initiatorname.iscsi` para adicioná-lo, e após a configuração no IBM, faça:

```bash
iscsiadm -m discovery -t sendtargets -p 172.16.100.50
iscsiadm -m node -T iqn.1986-03.com.ibm:2145.ibmcead.node1 -p 172.16.100.50 --op update -n node.startup -v automatic
iscsiadm -m node -T iqn.1986-03.com.ibm:2145.ibmcead.node2 -p 172.16.100.51 --op update -n node.startup -v automatic
iscsiadm -m node --login
iscsiadm -m node --rescan
```

## Criação de usuário para o CGCO

```bash
adduser -G users cgco
passwd cgco
```

E adicionar no final de `/etc/ssh/sshd_config`

```conf
Match User cgco
    X11Forwarding no
    AllowTcpForwarding no
    ForceCommand internal-sftp
    ChrootDirectory /media/ibm/cgco
```

Permissões corretas das pastas:

```bash
chown root:root /media/ibm/cgco
chmod 755 /media/ibm/cgco
chown cgco:users /media/ibm/cgco/moodle
chmod 775 /media/ibm/cgco/moodle
chown -R cgco:users /media/ibm/cgco/.ssh
chmod 700 /media/ibm/cgco/.ssh
chmod 600 /media/ibm/cgco/.ssh/authorized_keys
```

Reiniciar o serviço

```bash
rc-service sshd restart
```

## Configurar _host_ da máquina do CEAD

- Copiar a pasta ssl (`/media/{truenas,ibm}/backups`) do nginx para tmp (verificar `setup.sh`)
- Executar `setup.sh`
- Colocar a senha correta em `/etc/msmtprc`
