!#/bin/bash

sudo apt-get update

sudo useradd nagios
sudo groupadd nagcmd
sudo usermod -a -G nagcmd nagios && sudo usermod -a -G nagcmd www-data

sudo apt-get install -y apache2
sudo usermod -a -G nagcmd www-data
sudo apt-get -y install software-properties-common
sudo apt-get -y install python-software-properties

sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update

sudo apt-get install -y php7.0 php5.6 php5.6-mysql php-gettext php5.6-mbstring php-xdebug libapache2-mod-php5.6 libapache2-mod-php7.0

sudo apt-get update
sudo apt-get install -y mysql-server
sudo mysql_secure_installation
sudo mysql_install_db


sudo apt-get install -y build-essential unzip openssl libssl-dev libgd2-xpm-dev xinetd apache2-utils

wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.1.1.tar.gz
tar -xvf nagios-4.*.tar.gz

cd nagios-4.*

./configure --with-nagios-group=nagios --with-command-group=nagcmd
make all
sudo make install
sudo make install-init
sudo make install-config
sudo make install-commandmode

sudo a2enmod rewrite && sudo a2enmod cgi
sudo cp sample-config/httpd.conf /etc/apache2/sites-available/nagios4.conf
sudo chmod 644 /etc/apache2/sites-available/nagios4.conf
sudo a2ensite nagios4.conf
sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
sudo service apache2 restart

sudo apt-get install net-snmp
sudo apt-get install net-snmp-utils

wget http://www.nagios-plugins.org/download/nagios-plugins-2.2.0.tar.gz
tar -xvf nagios-plugins-2*.tar.gz


cd nagios-plugins-2.*
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
make
sudo make install

sudo mv /tmp/nagios.service /etc/systemd/system/nagios.service

sudo service nagios start
sudo systemctl enable /etc/systemd/system/nagios.service
sudo systemctl start nagios
systemctl status nagios


# Configurar correo


sudo apt-get install -y mailutils
sudo apt-get install -y msmtp-mta
cp /tmp/.msmtprc ~/.msmtprc
chmod 600 ~/.msmtprc

sudo apt-get install -y heirloom-mailx
cp /tmp/.mailrc ~/.mailrc

### Lo de arriba funciona mal

sudo apt-get install ssmtp
sudo nano /etc/ssmtp/ssmtp.conf # Modificar
usermod -a -G mail nagios
