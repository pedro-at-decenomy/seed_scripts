systemctl stop sapphire 
pkill -9 sapphired

wget https://github.com/sappcoin-com/SAPP/releases/download/v1.4.1.0/SAPP-1.4.1.0-Linux.zip
unzip SAPP-1.4.1.0-Linux.zip
rm SAPP-1.4.1.0-Linux.zip
mv sapphire* /usr/local/bin

systemctl start sapphire

watch sapphire-cli getinfo
