#!/bin/bash

#Install Nextcloud 17 sur ubuntu 18.04
#https://www.c-rieger.de/nextcloud-installation-guide-ubuntu-18-04/
#Conteneur Proxmox: Ubuntu-18.04-standard_18.04.1-1_amd64.tar.gz

apt update && apt full-upgrade -y

# Restart services during package upgrades without asking? Yes

# dependances
apt install curl
apt install gnupg2
apt install git
apt install apt-transport-https
apt install tree
apt install locate
apt install software-properties-common
apt install screen
apt install htop
apt install zip
apt install ffmpeg
apt install ghostscript
apt install libfile-fcntllock-perl

# install Apache2
apt install apache2

# install PHP
add-apt-repository ppa:ondrej/php
apt update
apt install php7.3
apt install php7.3-fpm
apt install php7.3-gd
apt install php7.3-mysql
apt install php7.3-curl
apt install php7.3-xml
apt install php7.3-zip
apt install php7.3-intl
apt install php7.3-mbstring
apt install php7.3-bz2
apt install php7.3-ldap
apt install php-apcu
apt install imagemagick
apt install php-imagick
apt install php-smbclient

# Configuration de PHP

timedatectl set-timezone Europe/Paris

date

cp /etc/php/$verphp/apache2/php.ini /etc/php/$verphp/apache2/php.ini.save

sed -i -e '/^;/d' /etc/php/7.3/apache2/php.ini

sed -i -e '/^$/d' /etc/php/7.3/apache2/php.ini


sed -i -e 's/memory_limit = 128M/memory_limit = 512M/' /etc/php/7.3/apache2/php.ini
sed -i -e 's/upload_max_filesize = 2M/upload_max_filesize = 1024M/' /etc/php/7.3/apache2/php.ini
sed -i -e 's/post_max_size = 8M/post_max_size = 1024M/' /etc/php/7.3/apache2/php.ini
sed -i -e 's/max_execution_time = 30/max_execution_time = 300/' /etc/php/7.3/apache2/php.ini
sed -i -e 's/max_input_time = 60/max_input_time = 600/' /etc/php/7.3/apache2/php.ini
sed -i -e 's/memory_limit = 128M/memory_limit = 512M/' /etc/php/7.3/apache2/php.ini


systemctl restart apache2

# install MariaDB
apt install mariadb-server

# Configuration de MariaDB

echo "
Suivre les instructions:
1 Définir un nouveau mdp ou garder le mot de passe du système. 
2 Effacer l’utilisateur anonymous pour des raisons de sécurité.
3 Désactiver la connexion sur la base de donnée avec le compte root à distance.
4 Effacer les bases de données de test.
5 Redémarrer les tables de droits.
"
sleep 5

mysql_secure_installation

mysql -u root -p << EOT      
CREATE DATABASE "$mariadatabase";
CREATE USER "$mariauser"@'localhost' IDENTIFIED BY "$mariapasswd";
GRANT ALL ON "$mariadatabase".* TO "$mariauser"@'localhost';
FLUSH PRIVILEGES;
> EOT     

########################################################

# Installation de Nextcloud
wget https://download.nextcloud.com/server/releases/nextcloud-"$vernext".zip
# Vérification de l’intégrité du document téléchargé
wget https://download.nextcloud.com/server/releases/nextcloud-"$vernext".zip.sha256
sha256sum  -c nextcloud-"$vernext".zip.sha256 < nextcloud-"$vernext".zip
# Extraction
apt install unzip
unzip nextcloud-"$vernext".zip
cp -R nextcloud /var/www/html/
# Configuration du serveur web
touch /etc/apache2/sites-available/default-ssl.conf
###
"###
####
####
####
systemctl reload apache2
a2enmod rewrite
systemctl reload apache2
a2enmod headers
service apache2 restart
a2enmod ssl
service apache2 restart
a2ensite default-ssl
service apache2 reload
chown -R www-data:www-data /var/www/html/nextcloud/
sudo -u "$usertos" firefox http://"$ipnet"/nextcloud
