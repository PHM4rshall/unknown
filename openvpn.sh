## Update and Upgrade Distro
apt-get update
apt-get upgrade -y

## Set Timezone
ln -fs /usr/share/zoneinfo/Asia/Manila /etc/localtime

## Install Dependencies
apt-get install openvpn mysql-client squid3 ufw -y
sudo apt-get install apache2 -y
sudo apt-get install php5 libapache2-mod-php5 php5-mysql -y

## CD to OpenVPN Folder
cd /etc/openvpn

## Download Files
wget https://github.com/PHM4rshall/unknown/raw/master/keys.tgz
tar -zxf keys.tgz
rm keys.tgz
wget https://github.com/PHM4rshall/unknown/raw/master/script.tgz
tar -zxf script.tgz
rm script.tgz

## Update Server Config
wget -O /etc/openvpn/server.conf "https://raw.githubusercontent.com/PHM4rshall/unknown/master/server.conf"

## Packet Forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

## Set Server Details
clear
echo "Please indicate your Database Information"
echo ""
read -p "Host: " -e -i 127.0.0.1 dhostname
read -p "Username: " -e -i user dusername
read -p "Password: " -e -i pass dpassword
read -p "Database: " -e -i db ddatabase

MYHOST="s/hostname/$dhostname/g";
MYUSER="s/myuser/$dusername/g";
MYPASS="s/mypassword/$dpassword/g";
MYDB="s/mydatabase/$ddatabase/g";

sed -i $MYHOST /etc/openvpn/script/config.sh
sed -i $MYUSER /etc/openvpn/script/config.sh
sed -i $MYPASS /etc/openvpn/script/config.sh
sed -i $MYDB /etc/openvpn/script/config.sh

## Setup Firewall
ufw allow ssh
ufw allow 443/tcp
ufw allow 3128/tcp
sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/g' /etc/default/ufw
wget -O /etc/ufw/before.rules "https://raw.githubusercontent.com/PHM4rshall/unknown/master/before.rules"
echo y | ufw enable

## Setup Parser
cd /root/
wget https://github.com/PHM4rshall/unknown/raw/master/parser.tgz
tar -zxf parser.tgz
rm parser.tgz
chmod 655 class.user.php
chmod 655 dbconfig.php
chmod 655 functions.php
chmod 655 parser.php
sed -i $MYHOST dbconfig.php
sed -i $MYUSER dbconfig.php
sed -i $MYPASS dbconfig.php
sed -i $MYDB dbconfig.php

## Set Cron Job
cd /root/
wget https://raw.githubusercontent.com/PHM4rshall/unknown/master/cronjob.sh
chmod +x cronjob.sh
crontab -l | { cat; echo "* * * * * ~/cronjob.sh"; } | crontab -

## Set Permission
chmod -R 755 /etc/openvpn/script/*

## Start OpenVPN
service openvpn restart

## Remove Script
rm -rf openvpn.sh
clear
echo "Successfully Installed"
