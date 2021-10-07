#!/bin/bash


#install recommended packages
echo "#####################################################################
# This script will install and Configure NRPE on RHEL 7
#####################################################################"
sleep 1

function installPRE(){
    yum install -y gcc glibc glibc-common gd gd-devel make net-snmp openssl-devel -q;
    mkdir /root/nagios;
    useradd nagios;
}

function installplugins(){
    cd /root/nagios/ || exit;
    wget https://www.nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz;
    tar -xvf nagios-plugins-2.3.3.tar.gz;
    cd nagios-plugins-2.3.3 || exit;
    ./configure --with-ping-command=ping;
    make;
    make install;
}

function usergroup() {
    chown -R nagios.nagios /usr/local/nagios/;
    usermod -a -G nagios nagios;
    chown -R nagios.nagios /usr/local/nagios/libexec;
    if cat /etc/services | grep nrpe
    then
        echo "NRPE Entry is already present"
    else
        echo "nrpe            5666/tcp                 NRPE" >> /etc/services;
    fi
}

#install xinetd(not requrired)
function xinet(){
  yum install -y xinetd -q;
}

function installNRPE(){
  cd /root/nagios/ || exit;
  echo "Downloading the NRPE package............";
  wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-4.0.3/nrpe-4.0.3.tar.gz;
  tar xzf nrpe-4.0.3.tar.gz;
  cd nrpe-4.0.3 || exit;
  ./configure;
  make all;
  make install-groups-users;
  make install;
  make install-config;
  make install-plugin;
  make install-inetd;
  make install-init;
}

# configure NRPE
function configureNRPE(){

    sed -i "s&allowed_hosts=127.0.0.1,::1&allowed_hosts=127.0.0.1,::1, <X.X.X.X>, <X.X.X.X>&" /usr/local/nagios/etc/nrpe.cfg;
    #adding entry in iptables
    echo "Adding entry in Firewalld service";
    systemctl start firewalld
    systemctl enable firewalld
    firewall-cmd --permanent --zone=public --add-port=5666/tcp
    firewall-cmd --reload
    sed -i '/^command\[check_hda1\]/c\command[check_disk]=/usr/local/nagios/libexec/check_disk -w 20% -c 10% -p /dev/xvda2 \ncommand[check_swap]=/usr/local/nagios/libexec/check_disk -w 20% -c 10% -p /dev/xvda1' /usr/local/nagios/etc/nrpe.cfg;
    systemctl restart firewalld
    systemctl restart nrpe.service;
    systemctl enable nrpe.service;

}

function checkservice(){
    echo "NRPE version";
    /usr/local/nagios/libexec/check_nrpe -H localhost;
    echo "NRPE service status";
    systemctl status nrpe.service;
    echo "NRPE port details";
    netstat -at | grep nrpe;
}
echo "#####################################################################
# Installing Dependancies................
#####################################################################"
sleep 2
installPRE;
sleep 2
echo "#####################################################################
# Installing nagios plugins...............
#####################################################################"
sleep 2
installplugins;
echo "#####################################################################
# Installation nagios plugins completed....
#####################################################################"
sleep 2
usergroup;
#echo "#####################################################################
# Installing xinetd service...............
#####################################################################"
#sleep 1
#xinet;
echo "#####################################################################
# Installing NRPE Package................
#####################################################################"
sleep 2
installNRPE;
echo "#####################################################################
# Configuring NRPE Package...............
#####################################################################"
sleep 2
configureNRPE;
sleep 2
echo "#####################################################################
# Validate configuration.................
#####################################################################"
sleep 5
checkservice;
