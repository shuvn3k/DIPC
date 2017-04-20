!#/bin/sh

sudo xcodebuild -license
sudo xcode-select --install

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install openssl

cd /tmp
curl -o macosx-nrpe-agent.tar.gz https://assets.nagios.com/downloads/nagiosxi/agents/macosx-nrpe-agent.tar.gz

tar xzf macosx-nrpe-agent.tar.gz
cd macosx
sudo ./fullinstall

#Realizar cambios en los ficheros de configuracion

sudo killall nrpe
/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d
