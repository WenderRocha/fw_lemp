#!/bin/bash
#
# Objetivo do script: instalar Nginx + Certbot, PHP (7.4 ou 8.2), MySQL.
# Feito para debian/ubuntu
#
# Desenvolvido por Felipe Barreto
###############################################################################################

# Qual timezone usar?
timezone="America/Sao_Paulo"

##############################################################################################
##############################################################################################
##############################################################################################
# Debug? (# = não)
# set -x
# Gerador de numero aleatório
int=$(shuf -i 10-100 -n 1)
# Gerador de senha aleatória para o admin do BD
password_db=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c34)

clear

echo "Iniciando o processo...."
# Define o timezone do servidor
timedatectl set-timezone $timezone > /dev/null 2>&1
# aplica atualizações
apt-get --yes --quiet update > /dev/null 2>&1

# Verifica se o apache já não está instalado
if [ -d "/etc/apache2" ]; then
 echo "!!! CUIDADO: Já existe uma instalação do apache. Verifique para evitar conflitos."; 
 exit;
else
# Se não estiver, instala o Nginx
 echo "NGINX: Iniciando instalação"
 apt-get --yes install nginx > /dev/null 2>&1
 ufw allow "Nginx Full" > /dev/null 2>&1
 echo "NGINX + SSL: Instalando certbot para apache..."
# Instalando certbot para nginx
 apt-get --yes install python3-certbot-nginx > /dev/null 2>&1
fi

# Perguntar qual versão do PHP instalar
echo "Qual versão do PHP você deseja instalar? (7.4 ou 8.2)"
read php_version

if [ "$php_version" == "7.4" ]; then
    echo "PHP: Iniciando instalação do PHP 7.4..."
    apt purge apache* --yes > /dev/null 2>&1
    apt install php7.4 -y --quiet > /dev/null 2>&1
    apt --yes install php7.4-cli php7.4-fpm php7.4-mysql php7.4-zip php7.4-gd php7.4-mbstring php7.4-curl php7.4-xml php7.4-bcmath php7.4-imagick php7.4-intl php7.4-soap > /dev/null 2>&1
    echo "PHP: php7.4-fpm foi instalado e está pronto para uso com Nginx"
elif [ "$php_version" == "8.2" ]; then
    echo "PHP: Iniciando instalação do PHP 8.2..."
    apt purge apache* --yes > /dev/null 2>&1
    apt install software-properties-common -y > /dev/null 2>&1
    add-apt-repository ppa:ondrej/php -y > /dev/null 2>&1
    apt update > /dev/null 2>&1
    apt install php8.2 -y --quiet > /dev/null 2>&1
    apt --yes install php8.2-cli php8.2-fpm php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml php8.2-bcmath php8.2-imagick php8.2-intl php8.2-soap > /dev/null 2>&1
    echo "PHP: php8.2-fpm foi instalado e está pronto para uso com Nginx"
else
    echo "Versão do PHP não reconhecida. Abortando a instalação."
    exit 1
fi

# Cria a credencial de admin
echo "MySQL: Iniciando a instalação do MySQL Server"
apt-get --yes --quiet install mysql-server > /dev/null 2>&1
mysql -e "create user admin_${int}@localhost IDENTIFIED WITH mysql_native_password BY '$password_db'" > /dev/null 2>&1
mysql -e "GRANT ALL PRIVILEGES ON *.* TO admin_${int}@localhost" > /dev/null 2>&1
mysql -e "FLUSH PRIVILEGES" > /dev/null 2>&1
cat > /root/.my.cnf << EOF
[client]
user=admin_${int}
password=$password_db
EOF
echo "MySQL: Instalação do MySQL concluída com sucesso"

#wget https://github.com/fabwebbr/lemp_fw/raw/main/modelo-vhost-nginx.txt -O /root/modelo-vhost-nginx.txt

clear
echo "-----------------------------------------------------------------"
echo "                     Instalação concluída                        "
echo "-----------------------------------------------------------------"
echo ""
#echo " Use o arquivo modelo 'modelo-vhost-nginx.txt' que está em seu "
#echo " '/root/' para criar um domínio em seu servidor."
echo ""
echo " Os dados de acesso ao seu MySQL pelo terminal são:"
echo " "
echo " Servidor: localhost (Porta 3306)"
echo " Usuário: admin_${int}"
echo " Senha: $password_db"
echo " "
echo " Com essas credenciais você pode gerenciar seus bancos de dados."
echo " "
echo " As credenciais de acesso ao MySQL (acesso via CLI) estão salvas "
echo " no arquivo /root/.my.cnf "
echo "-----------------------------------------------------------------"
