## Falta

-   _Scripts_ adicionais de verificação do Moodle

## O que tem neste repositório?

-   Configuração para um _host_ Alpine GNU/Linux, que prepara o ambiente para a execução do _site_ e sistema do CEAD
-   Clonar em `/srv` para compatibilidade dos _scripts_

## Instalação GNU/Linux Alpine

-   **No R900**, antes de iniciar a instalação, carregue o módulo megaraid_sas: `modprobe megaraid_sas`, e;
-   Antes de reiniciar pelo instalador, Coloque a _string_ `megaraid_sas` em `/etc/modules`, e;
-   Atualize o `initramfs` e o `extlinux.conf` com o comando `update-kernel`, e;
-   Execute `update-extlinux`, `dd if=/usr/share/syslinux/mbr.bin of=/dev/sda`, `sync`
-   Então reinicie.

## Instalação dos pacotes necessários

Depois de instalar o GNU/Linux Alpine, descomente a linha com `community` em `/etc/apk/repositories`

```bash
vi /etc/apk/repositories
```

Atualize e baixe os pacotes necessários

```bash
apk update
apk add ca-certificates docker docker-compose git logrotate mailx msmtp nfs-utils nginx open-iscsi rsync util-linux
update-ca-certificates
rc-update add docker boot
rc-update add nginx default
rc-update add iscsid default
rc-update add netmount default
rc-update add nfsmount default
rc-service docker start
rc-service iscsid start
```

Configure o IBM (172.16.100.40) para ser mapeado no _host_

-   Verifique o arquivo `/etc/iscsi/initiatorname.iscsi` para adicioná-lo, e após a configuração no IBM, faça:

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

-   Copiar a pasta /usr/local/etc/nginx/ssl to Torresmo para a pasta /tmp (verificar `setup.sh`)
-   Executar `setup.sh`
-   Colocar a senha correta em `/etc/msmtprc`
