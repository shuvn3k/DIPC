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


# Configurar cliente linux

sudo apt-get update
sudo apt-get install build-essential libssl-dev

cd /opt
sudo wget https://github.com/NagiosEnterprises/nrpe/archive/3.0.1.tar.gz
sudo tar xvfz 3.0.1.tar.gz
cd nrpe-3.0.1
sudo ./configure --enable-command-args
sudo make all
sudo make install-plugin

sudo apt-get update
sudo apt-get install nagios-nrpe-plugin

sudo ln -s /usr/lib/nagios/plugins/check_nrpe /usr/bin/check_nrpe



sudo apt-get update
sudo useradd nagios
sudo groupadd nagcmd

sudo add-apt-repository ppa:nagiosinc/ppa
sudo apt-get -y install software-properties-common
sudo apt-get -y install python-software-properties
sudo add-apt-repository ppa:nagiosinc/ppa
sudo apt-get update

wget http://nagios-plugins.org/download/nagios-plugins-2.0.3.tar.gz
tar xzf nagios-plugins-2.0.3.tar.gz
cd nagios-plugins-2.0.3/
sudo apt-get -y install build-essential libssl-dev xinetd
./configure
make
sudo make install

sudo chown nagios.nagios /usr/local/nagios/
sudo chown -R nagios.nagios /usr/local/nagios/libexec/

wget http://sourceforge.net/projects/nagios/files/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz
tar xzf nrpe-2.15.tar.gz

cd nrpe-2.15/
./configure --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu

sudo make all
sudo make install-plugin
sudo make install-daemon
make install-daemon-config
sudo make install-daemon-config
sudo make install-xinetd
sudo nano /etc/xinetd.d/nrpe
#Añadir
# default: on
# description: NRPE (Nagios Remote Plugin Executor)
service nrpe
{
    flags           = REUSE
    socket_type     = stream
    port            = 5666
    wait            = no
    user            = nagios
    group           = nagios
    server          = /usr/local/nagios/bin/nrpe
    server_args     = -c /usr/local/nagios/etc/nrpe.cfg --inetd
    log_on_failure  += USERID
    disable         = no
    only_from       = 127.0.0.1 10.0.2.15 192.168.34.151 192.168.34.1
    }

sudo nano /etc/services
#Añadir
nrpe            5666/tcp                        # nrpe

sudo service xinetd restart
sudo service networking restart
netstat -at | grep nrpe

sudo nano /etc/sudoers
#Añadir
nagios    ALL=(ALL)   NOPASSWD:/usr/local/nagios/libexec/

sudo nano /usr/local/nagios/etc/nrpe.cfg
#Añadir
command[check_mem]=/usr/local/nagios/libexec/check_mem -w 70 -c 90 -W 70 -C 90
command[check_cpu]=/usr/local/nagios/libexec/check_cpu -w 70 -c 90
command[check_uptime]=/usr/local/nagios/libexec/check_uptime
command[check_disk]=/usr/local/nagios/libexec/check_disk -w $ARG1$ -c $ARG2$ -p /

cd /usr/local/nagios/libexec/
sudo wget https://raw.githubusercontent.com/taha-bindas/openstack_nagios/master/check_cpu
sudo chmod +x check_cpu
sudo chown nagios. check_cpu

sudo curl -O https://raw.githubusercontent.com/shuvn3k/DIPC/master/nagios_plugins/check_mem
sudo chmod +x check_mem
sudo chown nagios. check_mem


#Otra manera mas sencilla

sudo apt-get update

wget http://assets.nagios.com/downloads/nagiosxi/agents/linux-nrpe-agent.tar.gz
tar xzf linux-nrpe-agent.tar.gz
cd linux-nrpe-agent
sudo ./fullinstall

cd /usr/local/nagios/libexec/
sudo wget https://raw.githubusercontent.com/taha-bindas/openstack_nagios/master/check_cpu
sudo chmod +x check_cpu
sudo chown nagios. check_cpu

sudo curl -O https://raw.githubusercontent.com/shuvn3k/DIPC/master/nagios_plugins/check_mem
sudo chmod +x check_mem
sudo chown nagios. check_mem

sudo nano /etc/sudoers
#Añadir
nagios    ALL=(ALL)   NOPASSWD:/usr/local/nagios/libexec/

sudo nano /usr/local/nagios/etc/nrpe.cfg
#Añadir
command[check_mem]=/usr/local/nagios/libexec/check_mem -w 70 -c 90 -W 70 -C 90
command[check_cpu]=/usr/local/nagios/libexec/check_cpu -w 70 -c 90
command[check_uptime]=/usr/local/nagios/libexec/check_uptime
command[check_disk]=/usr/local/nagios/libexec/check_disk -w $ARG1$ -c $ARG2$ -p /
