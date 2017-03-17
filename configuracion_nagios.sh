#!/bin/bash

sudo useradd nagios
sudo groupadd nagcmd
sudo usermod -a -G nagcmd nagios

sudo apt-get update

sudo apt-get install -y apache2
sudo usermod -a -G nagcmd apache
sudo apt-get -y install software-properties-common
sudo apt-get -y install python-software-properties

sudo add-apt-repository ppa:ondrej/php
sudo apt-get update

sudo apt-get install php7.0 php5.6 php5.6-mysql php-gettext php5.6-mbstring php-xdebug libapache2-mod-php5.6 libapache2-mod-php7.0

sudo apt-get update
sudo apt-get install mysql-server
sudo mysql_secure_installation
sudo mysql_install_db


apt-get install libapache2-mod-php
sudo apt-get install -y php
sudo apt-get install -y mysql-client-core-5.7

sudo apt-get install -y build-essential libgd2-xpm-dev openssl libssl-dev xinetd apache2-utils unzip

cd ~
curl -L -O https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.1.1.tar.gz

tar xvf nagios-*.tar.gz
cd nagios-*

./configure --with-nagios-group=nagios --with-command-group=nagcmd
make all

sudo make install
sudo make install-commandmode
sudo make install-init
sudo make install-config
sudo /usr/bin/install -c -m 644 sample-config/httpd.conf /etc/apache2/sites-available/nagios.conf

sudo usermod -G nagcmd www-data

cd ~
curl -L -O http://nagios-plugins.org/download/nagios-plugins-2.1.1.tar.gz
tar xvf nagios-plugins-*.tar.gz

cd nagios-plugins-*
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl

make
sudo make install

cd ~
curl -L -O http://downloads.sourceforge.net/project/nagios/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz
tar xvf nrpe-*.tar.gz

cd nrpe-*
./configure --enable-command-args --with-nagios-user=nagios --with-nagios-group=nagios --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu

make all
sudo make install
sudo make install-xinetd
sudo make install-daemon-config

#sed -i 's/only_from       = 127.0.0.1/only_from       = 127.0.0.1 158.227.172.30/' /etc/xinetd.d/nrpe

sudo service xinetd restart

sed -i 's/\#cfg_dir=\/usr\/local\/nagios\/etc\/servers/cfg_dir=\/usr\/local\/nagios\/etc\/servers/' /usr/local/nagios/etc/nagios.cfg

sudo mkdir /usr/local/nagios/etc/servers

sed -i 's/nagios@localhost/enamoya2@gmail.com/' /usr/local/nagios/etc/objects/contacts.cfg

echo 'define command{
        command_name check_nrpe
        command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
}' >> /usr/local/nagios/etc/objects/commands.cfg

sudo a2enmod rewrite
sudo a2enmod cgi

echo 'nagiosadmin:$apr1$xot7tWts$xDZNrGNgJ6UikqfqP/0Et.' | tee -a /usr/local/nagios/etc/htpasswd.users

sudo ln -s /etc/apache2/sites-available/nagios.conf /etc/apache2/sites-enabled/

sudo service nagios start
sudo service apache2 restart

sudo ln -s /etc/init.d/nagios /etc/rcS.d/S99nagios


# Desistalar nagios
sudo service nagios stop
sudo a2dissite nagios
sudo rm /etc/apache2/sites-available/nagios.conf
sudo deluser nagios
sudo delgroup nagcmd
sudo rm  /etc/init.d/nagios
sudo rm -r /usr/local/nagios/


# instalar check_nrpe

sudo apt-get update
sudo apt-get install build-essential libssl-dev

wget https://github.com/NagiosEnterprises/nrpe/archive/3.0.1.tar.gz
tar xvfz nrpe-3.0.1.tar.gz
cd nrpe-3.0.1
sudo ./configure --enable-command-args
sudo make all
sudo make install-plugin

sudo apt-get update
sudo apt-get install nagios-nrpe-plugin

sudo ln -s /usr/lib/nagios/plugins/check_nrpe /usr/bin/check_nrpe
