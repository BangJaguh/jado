#BY: @judiba
#R3V1V3R VPS
#Data de criaÃ§Ã£o: 26/04/2017
#Nome: ConfVPS05 - PackVPS 2.0"
clear
echo -e "\033[01;34mConfVPS05"
echo ""
echo -e "\033[01;36m       BY: @judiba                 
       R3V1V3R VPS                 
       Data de AtualizaÃ§Ã£o: 18/05/2017 
       OpenVPN Instalar ou Remover
       Nome: PackVPS 2.0           \033[1;37m"
echo ""
read -p "De enter para continuar..."
clear
tput setaf 8 ; tput setab 5; tput bold ; printf '%30s%s%-15s\n' "OpenVPN Manager" ; tput sgr0
echo ""

corPadrao="\033[0m"
preto="\033[0;30m"
vermelho="\033[0;31m"
verde="\033[0;32m"
marrom="\033[0;33m"
azul="\033[0;34m"
purple="\033[0;35m"
cyan="\033[0;36m"
cinzaClaro="\033[0;37m"
pretoCinza="\033[1;30m"
vermelhoClaro="\033[1;31m"
verdeClaro="\033[1;32m"
amarelo="\033[1;33m"
azulClaro="\033[1;34m"
purpleClaro="\033[1;35m"
cyanClaro="\033[1;36m"
branco="\033[1;37m"

# OpenVPN intalador para Debian, Ubuntu e o CentOS
touch /root/openclientes.db
mkdir /home/loginslimitados/
mkdir /root/arquivosopenvpn/
mkdir /home/opencliente/
mkdir /var/www/html/openvpn/
chmod -R 755 /var/www
touch /etc/r3v1v3r/backupOpenclientes.db
touch /etc/pam.d/openvpn
echo "
auth    required        pam_unix.so    shadow    nodelay
auth    requisite       pam_succeed_if.so uid >= 500 quiet
account required        pam_unix.so" >> /etc/pam.d/openvpn
clear

# mas irÃ¡ funcionar se vocÃª simplesmente deseja configurar uma VPN no 
# seu Debian/Ubuntu/CentOS. Ele foi projetado para ser tÃ£o
# discreto e universal quanto possÃ­vel.

# Detect Debian users running the script with "sh" instead of bash
if readlink /proc/$$/exe | grep -qs "dash"; then
	echo "Este script precisa ser executado com o interpretador bash, nÃ£o com o interpretador sh."
	exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
	echo "Desculpe, vocÃª precisa executar esse script como root."
	exit 2
fi

if [[ ! -e /dev/net/tun ]]; then
	echo "O Adaptador TUN nÃ£o estÃ¡ disponÃ­vel. Entre em contato com o suporte do seu serviÃ§o de hospedagem."
	exit 3
fi

if grep -qs "CentOS release 5" "/etc/redhat-release"; then
	echo "CentOS 5 estÃ¡ desatualizado, use um sistema mais recente."
	exit 4
fi
if [[ -e /etc/debian_version ]]; then
	OS=debian
	GROUPNAME=nogroup
	RCLOCAL='/etc/rc.local'
elif [[ -e /etc/centos-release || -e /etc/redhat-release ]]; then
	OS=centos
	GROUPNAME=nobody
	RCLOCAL='/etc/rc.d/rc.local'
	# Needed for CentOS 7
	chmod +x /etc/rc.d/rc.local
else
	echo "Este script roda somente em Distros: Debian, Ubuntu ou CentOS."
	exit 5
fi

newclient () {
	# Generates the custom client.ovpn
	cp /etc/openvpn/client-common.txt ~/arquivosopenvpn/$1.ovpn
	echo "<ca>" >> ~/arquivosopenvpn/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/ca.crt >> ~/arquivosopenvpn/$1.ovpn
	echo "</ca>" >> ~/arquivosopenvpn/$1.ovpn
	echo "<cert>" >> ~/arquivosopenvpn/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/issued/$1.crt >> ~/arquivosopenvpn/$1.ovpn
	echo "</cert>" >> ~/arquivosopenvpn/$1.ovpn
	echo "<key>" >> ~/arquivosopenvpn/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/private/$1.key >> ~/arquivosopenvpn/$1.ovpn
	echo "</key>" >> ~/arquivosopenvpn/$1.ovpn
	echo "<tls-auth>" >> ~/arquivosopenvpn/$1.ovpn
	cat /etc/openvpn/ta.key >> ~/arquivosopenvpn/$1.ovpn
	echo "</tls-auth>" >> ~/arquivosopenvpn/$1.ovpn
}

# Try to get our IP from the system and fallback to the Internet.
# I do this to make the script compatible with NATed servers (lowendspirit.com)
# and to avoid getting an IPv6.
IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
if [[ "$IP" = "" ]]; then
		IP=$(wget -qO- ipv4.icanhazip.com)
fi
tput setaf 8 ; tput setab 5 ; tput bold ; printf '%30s%s%-15s\n' "OpenVPN" ; tput sgr0
echo ""
echo -e '\033[01;34mOBS: Digite o que deseja fazer\033[1;34m'
echo -e '\033[01;34mEscolha uma opÃ§Ã£o: Para Sair Ctrl + C \033[1;33m'
echo -e '\033[05;31m-------------------------------------------------------\033[00;37m'
echo -e '\033[01;33m[1]\033[01;32m Instalar o OpenVPN\033[0m'
echo -e '\033[01;33m[2]\033[01;32m Criar usuÃ¡rio OpenVPN.\033[0m'
echo -e '\033[01;33m[3]\033[01;32m Deletar usuÃ¡rio OpenVPN.\033[0m'
echo -e '\033[01;33m[4]\033[01;32m Desinstalar o OpenVPN.\033[0m'
echo -e '\033[01;33m[5]\033[01;32m Renovar usuÃ¡rio OpenVPN.'
echo -e '\033[05;31m-------------------------------------------------------\033[00;37m'
echo ""
read -p "Responda: " resposta
if [[ "$resposta" = '1' ]]; then 
	clear
	if [[ -e /etc/openvpn/server.conf ]]; then
	echo "OpenVPN jÃ¡ estÃ¡ instalado. "
	exit
	fi
	clear
	echo "Script original: https://github.com/Nyr/openvpn-install"
	echo ""
	echo "Primeiro precisa confirmar o seu endereÃ§o IPv4 da interface de rede externa do seu servidor."
	read -p "EndereÃ§o IP: " -e -i $IP IP
	echo ""
	echo "Em qual porta vocÃª quer rodar o OpenVPN?"
	read -p "Porta: " -e -i 8090 PORT
	echo ""
	echo "Qual DNS vocÃª quer usar com este VPN?"
	echo ""
	echo "   1) DNS PadrÃ£o do Sistema"
	echo "   2) Google"
	echo "   3) OpenDNS"
	echo "   4) NTT"
	echo "   5) Level 3"
	echo "   6) Verisign"
	echo ""
	read -p "DNS [1-6]: " -e -i 1 DNS
	echo ""
	echo "Pronto, agora me diga um nome para o certificado do usuÃ¡rio."
	echo "Por favor, use apenas uma Ãºnica palavra, sem caracteres especiais."
	echo ""
	read -p "Nome do usuÃ¡rio: " -e -i cliente CLIENT
	echo ""
	echo "Certo, isso Ã© tudo o que eu precisava. NÃ³s jÃ¡ estamos prontos para configurar o seu servidor OpenVPN"
	echo ""
	read -n1 -r -p "Aperte qualquer tecla para continuar..."
	if [[ "$OS" = 'debian' ]]; then
		apt-get update
		apt-get install openvpn iptables openssl ca-certificates -y
	else
		# Else, the distro is CentOS
		yum install epel-release -y
		yum install openvpn iptables openssl wget ca-certificates -y
	fi
	# An old version of easy-rsa was available by default in some openvpn packages
	if [[ -d /etc/openvpn/easy-rsa/ ]]; then
		rm -rf /etc/openvpn/easy-rsa/
	fi
	# Get easy-rsa
	wget -O ~/EasyRSA-3.0.1.tgz https://github.com/OpenVPN/easy-rsa/releases/download/3.0.1/EasyRSA-3.0.1.tgz
	tar xzf ~/EasyRSA-3.0.1.tgz -C ~/
	mv ~/EasyRSA-3.0.1/ /etc/openvpn/
	mv /etc/openvpn/EasyRSA-3.0.1/ /etc/openvpn/easy-rsa/
	chown -R root:root /etc/openvpn/easy-rsa/
	rm -rf ~/EasyRSA-3.0.1.tgz
	cd /etc/openvpn/easy-rsa/
	# Create the PKI, set up the CA, the DH params and the server + client certificates
	./easyrsa init-pki
	./easyrsa --batch build-ca nopass
	./easyrsa gen-dh
	./easyrsa build-server-full server nopass
	./easyrsa build-client-full $CLIENT nopass
	./easyrsa gen-crl
	# Move the stuff we need
	cp pki/ca.crt pki/private/ca.key pki/dh.pem pki/issued/server.crt pki/private/server.key /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn
	# CRL is read with each client connection, when OpenVPN is dropped to nobody
	chown nobody:$GROUPNAME /etc/openvpn/crl.pem
	# Generate key for tls-auth
	openvpn --genkey --secret /etc/openvpn/ta.key
	# Generate server.conf
	echo "port $PORT
proto tcp-server
dev tun
sndbuf 0
rcvbuf 0
ca ca.crt
cert server.crt
key server.key
dh dh.pem
tls-auth ta.key 0
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt" > /etc/openvpn/server.conf
	echo 'push "redirect-gateway def1 bypass-dhcp"' >> /etc/openvpn/server.conf
	# DNS
	case $DNS in
		1) 
		# Obtain the resolvers from resolv.conf and use them for OpenVPN
		grep -v '#' /etc/resolv.conf | grep 'nameserver' | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | while read line; do
			echo "push \"dhcp-option DNS $line\"" >> /etc/openvpn/server.conf
		done
		;;
		2) 
		echo 'push "dhcp-option DNS 8.8.8.8"' >> /etc/openvpn/server.conf
		echo 'push "dhcp-option DNS 8.8.4.4"' >> /etc/openvpn/server.conf
		;;
		3)
		echo 'push "dhcp-option DNS 208.67.222.222"' >> /etc/openvpn/server.conf
		echo 'push "dhcp-option DNS 208.67.220.220"' >> /etc/openvpn/server.conf
		;;
		4) 
		echo 'push "dhcp-option DNS 129.250.35.250"' >> /etc/openvpn/server.conf
		echo 'push "dhcp-option DNS 129.250.35.251"' >> /etc/openvpn/server.conf
		;;
		5) 
		echo 'push "dhcp-option DNS 4.2.2.3"' >> /etc/openvpn/server.conf
		echo 'push "dhcp-option DNS 4.2.2.4"' >> /etc/openvpn/server.conf
		;;
		6) 
		echo 'push "dhcp-option DNS 64.6.64.6"' >> /etc/openvpn/server.conf
		echo 'push "dhcp-option DNS 64.6.65.6"' >> /etc/openvpn/server.conf
		;;
	esac
	echo "keepalive 10 120
cipher AES-256-CBC
comp-lzo
plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so openvpn
user nobody
group $GROUPNAME
persist-key
persist-tun
status openvpn-status.log
verb 3
crl-verify crl.pem" >> /etc/openvpn/server.conf
	# Enable net.ipv4.ip_forward for the system
	sed -i '/\<net.ipv4.ip_forward\>/c\net.ipv4.ip_forward=1' /etc/sysctl.conf
	if ! grep -q "\<net.ipv4.ip_forward\>" /etc/sysctl.conf; then
		echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
	fi
	# Avoid an unneeded reboot
	echo 1 > /proc/sys/net/ipv4/ip_forward
    # Needed to use rc.local with some systemd distros
	if [[ "$OS" = 'debian' && ! -e $RCLOCAL ]]; then
		echo '#!/bin/sh -e
exit 0' > $RCLOCAL
    fi
    chmod +x $RCLOCAL
	# Set NAT for the VPN subnet
	iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to $IP
	sed -i "1 a\iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to $IP" $RCLOCAL
	if pgrep firewalld; then
		# We don't use --add-service=openvpn because that would only work with
		# the default port. Using both permanent and not permanent rules to
		# avoid a firewalld reload.
		firewall-cmd --zone=public --add-port=$PORT/udp
		firewall-cmd --zone=trusted --add-source=10.8.0.0/24
		firewall-cmd --permanent --zone=public --add-port=$PORT/udp
		firewall-cmd --permanent --zone=trusted --add-source=10.8.0.0/24
	fi
	if iptables -L -n | grep -qE 'REJECT|DROP'; then
		# If iptables has at least one REJECT rule, we asume this is needed.
		# Not the best approach but I can't think of other and this shouldn't
		# cause problems.
		iptables -I INPUT -p tcp --dport $PORT -j ACCEPT
		iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT
		iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
		sed -i "1 a\iptables -I INPUT -p tcp --dport $PORT -j ACCEPT" $RCLOCAL
		sed -i "1 a\iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT" $RCLOCAL
		sed -i "1 a\iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT" $RCLOCAL
	fi
	# If SELinux is enabled and a custom port was selected, we need this
	if hash sestatus 2>/dev/null; then
		if sestatus | grep "Current mode" | grep -qs "enforcing"; then
			if [[ "$PORT" != '8090' ]]; then
				# semanage isn't available in CentOS 6 by default
				if ! hash semanage 2>/dev/null; then
					yum install policycoreutils-python -y
				fi
				semanage port -a -t openvpn_port_t -p tcp $PORT
			fi
		fi
	fi
	# And finally, restart OpenVPN
	if [[ "$OS" = 'debian' ]]; then
		# Little hack to check for systemd
		if pgrep systemd-journal; then
			systemctl restart openvpn@server.service
		else
			/etc/init.d/openvpn restart
		fi
	else
		if pgrep systemd-journal; then
			systemctl restart openvpn@server.service
			systemctl enable openvpn@server.service
		else
			service openvpn restart
			chkconfig openvpn on
		fi
	fi
	# Try to detect a NATed connection and ask about it to potential LowEndSpirit users
	EXTERNALIP=$(wget -qO- ipv4.icanhazip.com)
	if [[ "$IP" != "$EXTERNALIP" ]]; then
		echo ""
		echo "Parece que seu servidor estÃ¡ atrÃ¡s de uma interface NAT!"
		echo ""
		echo "Se seu servidor usa NAT (ex. LowEndSpirit), Eu preciso saber o endereÃ§o IP externo."
		echo "Se nÃ£o for o caso, apenas ignore isso e deixe o prÃ³ximo campo em branco."
		read -p "IP Externo: " -e USEREXTERNALIP
		if [[ "$USEREXTERNALIP" != "" ]]; then
			IP=$USEREXTERNALIP
		fi
	fi
	# client-common.txt is created so we have a template to add further users later
	echo "client
dev tun
proto tcp-client
sndbuf 0
rcvbuf 0
remote $IP $PORT
http-proxy-option CUSTOM-HEADER X-Online-Host  sdp.vivo.com.br
http-proxy $IP 80
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
comp-lzo
setenv opt block-outside-dns
key-direction 1
auth-user-pass
auth-nocache
#http-proxy 127.0.0.1 1707
#route $IP 255.255.255.255 net_gateway
#http-proxy-retry
#http-proxy-timeout 30
verb 3" > /etc/openvpn/client-common.txt
	# Generates the custom client.ovpn
	newclient "$CLIENT"
	echo ""
	echo "O Certificado do usuÃ¡rio $CLIENT estÃ¡ disponÃ­vel em ~/arquivosopenvpn/$CLIENT.ovpn"
	echo ""
elif [[ "$resposta" = '2' ]]; then
	clear
	echo ""
    echo "--------------------------------------------------"
	echo "Digite o nome do usuÃ¡rio OpenVPN que deseja criar:"
	echo "Evite caracteres especiais."
    echo "--------------------------------------------------"
	echo ""
	read -p "Nome do usuÃ¡rio: " CLIENT
	awk -F : ' { print $1 }' /etc/passwd > /tmp/users 
	if grep -Fxq "$CLIENT" /tmp/users
	then
                while true
                do
                	clear
			echo "----------------------------"
			echo "usuÃ¡rio OpenVPN jÃ¡ existe..."
			echo " "
			echo "Digite o nome do usuÃ¡rio OpenVPN que deseja criar:"
			echo "Evite caracteres especiais."
        		echo "--------------------------------------------------"
			read -p "Nome do usuÃ¡rio: " CLIENT
                        awk -F : ' { print $1 }' /etc/passwd > /tmp/users 
			if grep -Fxq "$CLIENT" /tmp/users
                        then

			        echo ""
			else
                                break
                        fi
		done
	fi
	cd /etc/openvpn/easy-rsa/
	./easyrsa build-client-full $CLIENT nopass
	# Generates the custom client.ovpn
	echo ""
	PASS=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1`;
    useradd -M -s /bin/false -d ~/arquivosopenvpn/$CLIENT
    echo "$CLIENT$PASS" | chpasswd
    echo "$CLIENT" > ~/arquivosopenvpn/pass.txt
    echo "$PASS" >> ~/arquivosopenvpn/pass.txt
    zip client.zip client.ovpn pass.txt
	cp ~/arquivosopenvpn/client.zip /var/www/html/openvpn/
   	clear
   	echo "----------------------------------"
	echo "Agora vamos definir a validade...."
	echo "Escolha primeiro o Dia, depois MÃŠS"
	echo "E por fim o ANO de validade. Este "
	echo "script jÃ¡ pre determina a validade"
	echo "com 1 mÃªs a frente entÃ£o basta "
	echo "pressionar ENTER e confirmar a"
	echo "data ou modifique caso deseje....."
	echo "----------------------------------"
	DIAD=$(date +%d)  
	MESM=$(date +%m)
	ANOA=$(date +%Y)
	MESNOVO=$(($MESM+01))
	MESNOVOZ=`seq -f "%02g" $MESNOVO $MESNOVO`
	read -p "Digite o DIA com dois dÃ­gitos: " -e -i $DIAD dia
	echo " "
	read -p "Digite o MÃŠS com dois dÃ­gitos: " -e -i $MESNOVOZ mes
	echo " "
	read -p "Digite o ANO com quatro dÃ­gitos: " -e -i $ANOA ano
	usermod -e "$ano"-"$mes"-"$dia" "$CLIENT"
        clear
        validade=("$ano$mes$dia")
        echo "$CLIENT $validade">> /root/openclientes.db
	echo "$CLIENT $validade">> /etc/r3v1v3r/backupOpenclientes.db
        echo "O Certificado do usuÃ¡rio $CLIENT estÃ¡ disponÃ­vel em /var/www/html/openvpn/$CLIENT.zip"
        echo "Para verificar basta acessar: http://$IP:88/openvpn/"
        echo "Para pegar este arquivo.ovpn use o navegador"
        echo " "
        echo "--------------------------------------------"
        echo "UsuÃ¡rio OpenVPN $CLIENT criado com sucesso"
	echo "a validade do cliente $CLIENT Ã©: $dia/$mes/$ano"
        echo "IP do servidor: $IP"
        echo "--------------------------------------------"
elif [[ "$resposta" = '3' ]]; then
	clear
	NUMBEROFCLIENTS=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep -c "^V")
	if [[ "$NUMBEROFCLIENTS" = '0' ]]; then
		echo ""
		echo "VocÃª nÃ£o tem nenhum usuÃ¡rio existente no OpenVPN!"
		exit
	fi
	echo ""
	echo "Qual usuÃ¡rio deseja remover?"
	tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | nl -s ') '
	if [[ "$NUMBEROFCLIENTS" = '1' ]]; then
		read -p "Selecione um usuÃ¡rio [1]: " CLIENTNUMBER
	else
		read -p "Selecione um usuÃ¡rio [1-$NUMBEROFCLIENTS]: " CLIENTNUMBER
	fi
	CLIENT=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | sed -n "$CLIENTNUMBER"p)
	cd /etc/openvpn/easy-rsa/
	./easyrsa --batch revoke $CLIENT
	./easyrsa gen-crl
	rm -rf pki/reqs/$CLIENT.req
	rm -rf pki/private/$CLIENT.key
	rm -rf pki/issued/$CLIENT.crt
	rm -rf /etc/openvpn/crl.pem
	cp /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/crl.pem
	# CRL is read with each client connection, when OpenVPN is dropped to nobody
	chown nobody:$GROUPNAME /etc/openvpn/crl.pem
	echo ""
        #Deletando Arquivo .ovpn
        arquivo=($CLIENT.ovpn)
        rm ~/arquivosopenvpn/$arquivo
        rm /var/www/html/openvpn/$arquivo
	userdel --force "$CLIENT"
        grep -v ^$CLIENT[[:space:]] /root/openclientes.db > /tmp/r3v1v3r ; cat /tmp/r3v1v3r > /root/openclientes.db
	grep -v ^$CLIENT[[:space:]] /etc/r3v1v3r/backupOpenclientes.db > /tmp/r3v1v3r ; cat /tmp/r3v1v3r > /etc/r3v1v3r/backupOpenclientes.db
        echo " "
	echo "UsuÃ¡rio $CLIENT removido"
	exit
elif [[ "$resposta" = '4' ]]; then
	clear
	#Esta parte Ã© direto do script do phreaker56.xyz
	#CrÃ©ditos a ele.
	echo "---------------------------------"
	read -p "Quer mesmo desinstalar o OpenVPN? [s/n]: " -e -i n REMOVE
	if [[ "$REMOVE" = 's' ]]; then
		PORT=$(grep '^port ' /etc/openvpn/server.conf | cut -d " " -f 2)
		if pgrep firewalld; then
			# Using both permanent and not permanent rules to avoid a firewalld reload.
			firewall-cmd --zone=public --remove-port=$PORT/tcp
			firewall-cmd --zone=trusted --remove-source=10.8.0.0/24
			firewall-cmd --permanent --zone=public --remove-port=$PORT/tcp
			firewall-cmd --permanent --zone=trusted --remove-source=10.8.0.0/24
		fi
		if iptables -L -n | grep -qE 'REJECT|DROP'; then
			sed -i "/iptables -I INPUT -p tcp --dport $PORT -j ACCEPT/d" $RCLOCAL
			sed -i "/iptables -I FORWARD -s 10.8.0.0\/24 -j ACCEPT/d" $RCLOCAL
			sed -i "/iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT/d" $RCLOCAL
		fi
		sed -i '/iptables -t nat -A POSTROUTING -s 10.8.0.0\/24 -j SNAT --to /d' $RCLOCAL
		if hash sestatus 2>/dev/null; then
			if sestatus | grep "Current mode" | grep -qs "enforcing"; then
				if [[ "$PORT" != '8090' ]]; then
					semanage port -d -t openvpn_port_t -p tcp $PORT
				fi
			fi
		fi
		if [[ "$OS" = 'debian' ]]; then
			apt-get remove --purge -y openvpn openvpn-blacklist
		else
			yum remove openvpn -y
		fi
		rm -rf /etc/openvpn
		rm -rf /usr/share/doc/openvpn*
		echo ""
		echo "OpenVPN desinstalado com sucesso!"
	else
		echo ""
		echo "A desinstalaÃ§Ã£o do OpenVPN foi cancelada!"
	fi
elif [[ "$resposta" = '5' ]]; then
        clear
        echo " "
	read -p "Nome do usuÃ¡rio OpenVPN para alterar a validade: " user
	if [[ -z $user ]]
	then
		echo ""
		tput setaf 7 ; tput setab 4 ; tput bold ; echo "VocÃª digitou um nome de usuÃ¡rio vazio ou invÃ¡lido!" ; tput sgr0
		echo ""
		exit 1
	else
		awk -F : ' { print $1 }' /etc/passwd > /tmp/users
		if grep -Fxq "$user" /tmp/users
		then
                	echo " "
        	else
                	clear
                	while true
                	do
				tput sgr0
				echo "----------------------------"
				echo "UsuÃ¡rio $user nÃ£o existe..."
				echo " "
				echo "Digite o nome do usuÃ¡rio OpenVPN que deseja renovar:"
        			echo "---------------------------------------------------------"
				read -p "Nome do usuÃ¡rio: " user
                        	awk -F : ' { print $1 }' /etc/passwd > /tmp/users 
				if grep -Fxq "$user" /tmp/users
                        	then
			        	break
				else
                                	echo " "
                        	fi
              done
        fi
        clear
		echo "----------------------------------"
		echo "Agora vamos definir a validade...."
		echo "Escolha primeiro o Dia, depois MÃŠS"
		echo "E por fim o ANO de validade. Este "
		echo "script jÃ¡ pre determina a validade"
		echo "com 1 mÃªs a frente entÃ£o basta "
		echo "pressionar ENTER e confirmar a"
		echo "data ou modifique caso deseje....."
		echo "----------------------------------"
		DIAD=$(date +%d)  
		MESM=$(date +%m)
       		ANOA=$(date +%Y)
		MESNOVO=$(($MESM+01))
		MESNOVOZ=`seq -f "%02g" $MESNOVO $MESNOVO`
		read -p "Digite o DIA com dois dÃ­gitos: " -e -i $DIAD dia
		echo " "
		read -p "Digite o MÃŠS com dois dÃ­gitos: " -e -i $MESNOVOZ mes
		echo " "
		read -p "Digite o ANO com quatro dÃ­gitos: " -e -i $ANOA ano
		clear
		usermod -e "$ano"-"$mes"-"$dia" "$user"
		echo " "
        echo " "
        validade=("$ano$mes$dia")
        grep -v ^$user[[:space:]] /root/openclientes.db > /tmp/mudar
		mv /tmp/mudar /root/openclientes.db
        echo "$user $validade">> /root/openclientes.db
        ##mudanca
        grep -v ^$user[[:space:]] etc/r3v1v3r/backupOpenclientes.db > /tmp/mudar
		mv /tmp/mudar etc/r3v1v3r/backupOpenclientes.db
		echo "$user $validade">> /etc/r3v1v3r/backupOpenclientes.db
		echo "-----------------------------------------------------------"
		echo "Validade do cliente $user alterada para: $dia/$mes/$ano"
        echo "IP do Servidor: $IP"
		echo "-----------------------------------------------------------"

	fi
else
        clear
	echo "---------------"
	echo "opÃ§Ã£o invalida!"
	echo "---------------"
        clear
fi
    
cd
	apt-get -y install nginx
	cat > /etc/nginx/nginx.conf <<END
user www-data;
worker_processes 2;
pid /var/run/nginx.pid;
events {
	multi_accept on;
        worker_connections 1024;
}
http {
	autoindex on;
        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        server_tokens off;
        include /etc/nginx/mime.types;
        default_type application/octet-stream;
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;
        client_max_body_size 32M;
	client_header_buffer_size 8m;
	large_client_header_buffers 8 8m;
	fastcgi_buffer_size 8m;
	fastcgi_buffers 8 8m;
	fastcgi_read_timeout 600;
        include /etc/nginx/conf.d/*.conf;
}
END
	mkdir -p /home/vps/public_html
	echo "<pre>by phutthasit2530 | phutthasit2530</pre>" > /home/vps/public_html/index.html
	echo "<?phpinfo(); ?>" > /home/vps/public_html/info.php
	args='$args'
	uri='$uri'
	document_root='$document_root'
	fastcgi_script_name='$fastcgi_script_name'
	cat > /etc/nginx/conf.d/vps.conf <<END
server {
    listen       85;
    server_name  127.0.0.1 localhost;
    access_log /var/log/nginx/vps-access.log;
    error_log /var/log/nginx/vps-error.log error;
    root   /home/vps/public_html;
    location / {
        index  index.html index.htm index.php;
	try_files $uri $uri/ /index.php?$args;
    }
    location ~ \.php$ {
        include /etc/nginx/fastcgi_params;
        fastcgi_pass  127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
END

	if [[ "$VERSION_ID" = 'VERSION_ID="7"' || "$VERSION_ID" = 'VERSION_ID="8"' || "$VERSION_ID" = 'VERSION_ID="14.04"' ]]; then
		if [[ -e /etc/squid3/squid.conf ]]; then
			apt-get -y remove --purge squid3
		fi

		apt-get -y install squid3
		cat > /etc/squid3/squid.conf <<END
http_port $PROXY
acl localhost src 127.0.0.1/32 ::1
acl to_localhost dst 127.0.0.0/8 0.0.0.0/32 ::1
acl localnet src 10.0.0.0/8
acl localnet src 172.16.0.0/12
acl localnet src 192.168.0.0/16
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777
acl CONNECT method CONNECT
acl SSH dst xxxxxxxxx-xxxxxxxxx/255.255.255.255
http_access allow SSH
http_access allow localnet
http_access allow localhost
http_access deny all
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .               0       20%     4320
END
		IP2="s/xxxxxxxxx/$IP/g";
		sed -i $IP2 /etc/squid3/squid.conf;
		if [[ "$VERSION_ID" = 'VERSION_ID="14.04"' ]]; then
			service squid3 restart
			/etc/init.d/openvpn restart
			/etc/init.d/nginx restart
		else
			/etc/init.d/squid3 restart
			/etc/init.d/openvpn restart
			/etc/init.d/nginx restart
		fi

	elif [[ "$VERSION_ID" = 'VERSION_ID="9"' || "$VERSION_ID" = 'VERSION_ID="16.04"' || "$VERSION_ID" = 'VERSION_ID="18.04"' ]]; then
		if [[ -e /etc/squid/squid.conf ]]; then
			apt-get -y remove --purge squid
		fi

		apt-get -y install squid
		cat > /etc/squid/squid.conf <<END
http_port $PROXY
acl localhost src 127.0.0.1/32 ::1
acl to_localhost dst 127.0.0.0/8 0.0.0.0/32 ::1
acl localnet src 10.0.0.0/8
acl localnet src 172.16.0.0/12
acl localnet src 192.168.0.0/16
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777
acl CONNECT method CONNECT
acl SSH dst xxxxxxxxx-xxxxxxxxx/255.255.255.255
http_access allow SSH
http_access allow localnet
http_access allow localhost
http_access deny all
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .               0       20%     4320
END
		IP2="s/xxxxxxxxx/$IP/g";
		sed -i $IP2 /etc/squid/squid.conf;
		/etc/init.d/squid restart
		/etc/init.d/openvpn restart
		/etc/init.d/nginx restart
	fi

fi


echo ""
echo -e "\033[0;32m { DOWNLOAD MENU SCRIPT }${NC} "
echo ""
	cd /usr/local/bin
wget -q -O m "https://raw.githubusercontent.com/phutthasit2530/openvpnauto/master/Menu"
chmod +x /usr/local/bin/m
	wget -O /usr/local/bin/Auto-Delete-Client "https://raw.githubusercontent.com/phutthasit2530/PURE/master/Auto-Delete-Client"
	chmod +x /usr/local/bin/Auto-Delete-Client 
	apt-get -y install vnstat
	cd /etc/openvpn/easy-rsa/
	./easyrsa build-client-full $CLIENT nopass
	newclient "$CLIENT"
	cp /root/$CLIENT.ovpn /home/vps/public_html/
	rm -f /root/$CLIENT.ovpn
	case $OPENVPNSYSTEM in
		2)
		useradd $Usernames
		echo -e "$Passwords\n$Passwords\n"|passwd $Usernames &> /dev/null
		;;
	esac
	
	
	clear
echo ""
echo ""
echo -e "${RED} =============== OS-32 & 64-bit =================    "
echo -e "${RED} #        AUTOSCRIPT CREATED BY ─━═हຫມາສີ້ແມ່ມືງह═━─         #    "
echo -e "${RED} #      -----------About Us------------         #    "
echo -e "${RED} #    OS  DEBIAN 7-8-9  OS  UBUNTU 14-16-18     #    "
echo -e "${RED} #       Truemoney Wallet : ─━═हຫມາສີ້ແມ່ມືງह═━─        #    "
echo -e "${RED} #               { VPN / SSH }                  #    "
echo -e "${RED} #         BY : ─━═हຫມາສີ້ແມ່ມືງह═━─               #    "
echo -e "${RED} #    FB : ─━═हຫມາສີ້ແມ່ມືງह═━─       #    "
echo -e "${RED} =============== OS-32 & 64-bit =================    "
echo -e "${GREEN} ไอพีเซิฟ: $IP "
echo -e "${NC} "
	echo "OpenVPN, Squid Proxy, Nginx .....Install finish."
	echo "IP Server : $IP"
	echo "Port Server : $PORT"
	if [[ "$PROTOCOL" = 'udp' ]]; then
		echo "Protocal : UDP"
	elif [[ "$PROTOCOL" = 'tcp' ]]; then
		echo "Protocal : TCP"
	fi
	echo "Port Nginx : 85"
	echo "IP Proxy : $IP"
	echo "Port Proxy : $PROXY"
	echo ""
	case $OPENVPNSYSTEM in
		1)
		echo "Download My Config : http://$IP:85/$CLIENT.ovpn"
		;;
		2)
		echo "Download Config : http://$IP:85/$CLIENT.ovpn"
		echo ""
		echo "Your Username : $Usernames"
		echo "Your Password : $Passwords"
		echo "Expire : Never"
		;;
		3)
		echo "Download Config : http://$IP:85/$CLIENT.ovpn"
		;;
	esac
	echo ""
	echo "===================================================================="
	echo -e "ติดตั้งสำเร็จ... กรุณาพิมพ์คำสั่ง${YELLOW} m ${NC} เพื่อไปยังขั้นตอนถัดไป"
	echo "===================================================================="
	echo ""
	exit
