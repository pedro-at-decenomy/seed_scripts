#!/bin/bash

# This script assumes either the user is root or it has a sudo permission

clear

# Install wget
echo -e "\033[0;34m### Installing wget\033[0m\n"
sudo apt install wget

# Create directory for binaries zip file and bootstrap.zip and change directory to it
mkdir tmp
cd tmp

# Download Sapphire v1.3.3.2 binaries and extract them
echo -e "\n\033[0;34m### Downloading Sapphire v1.3.3.2 binaries and installing them\033[0m\n"
wget https://github.com/sappcoin-com/SAPP/releases/download/v1.3.3.2/SAPP-1.3.3.2-Linux.zip
unzip SAPP-1.3.3.2-Linux.zip

# Install Sapphire v1.3.3.2 binaries to /usr/local/bin and create $HOME/.sap (Sapphire data directory)
sudo mv sapd sap-cli sap-tx sap-qt /usr/local/bin/
mkdir $HOME/.sap

# Download bootstrap and extract it into Sapphire data directory
echo -e "\n\033[0;34m### Downloading bootstrap and extracting it into Sapphire data directory\033[0m\n"
wget http://sappexplorer.com/bootstrap.zip
unzip -q bootstrap.zip -d $HOME/.sap

# Change directory to $HOME and remove tmp directory
cd $HOME
rm -fr tmp

# Create empty sap.conf file and fill it with arguments
echo -e "\n\033[0;34m### Creating sap.conf and populating it\033[0m\n"
touch .sap/sap.conf
echo "daemon=1" >> .sap/sap.conf
echo "server=1" >> .sap/sap.conf
echo "addnode=seed1.sappcoin.com" >> .sap/sap.conf
echo "addnode=seed2.sappcoin.com" >> .sap/sap.conf
echo "addnode=seed3.sappcoin.com" >> .sap/sap.conf
echo "addnode=seed4.sappcoin.com" >> .sap/sap.conf
echo "addnode=seed5.sappcoin.com" >> .sap/sap.conf
echo "addnode=seed6.sappcoin.com" >> .sap/sap.conf
echo "addnode=seed7.sappcoin.com" >> .sap/sap.conf
echo "addnode=seed8.sappcoin.com" >> .sap/sap.conf
echo "banaddressmempool=SfFQ3twBcziZAHMeULnrDSemaqZqHUpmj4" >> .sap/sap.conf
echo "banaddressmempool=SPixuKa8Vnyi6RpcB8XTXh7TBqq6TqZ43b" >> .sap/sap.conf

# Start the Sapphire v1.3.3.2 daemon
echo -e "\n\033[0;34m### Running the daemon. Please wait. This will take 20 seconds.\033[0m\n"
/usr/local/bin/sapd

# Wait 20 seconds for the daemon starts
sleep 20

# Send some new lines
echo -e "\n\n"

# Request a new address with the "label":"stakingAddress1"
echo -e "\033[0;34m### Creating a new address labeled as 'stakingAddress1'\033[0m\n"
sap-cli getnewaddress "stakingAddress1"

# Wait 3 seconds
sleep 3

# Alert user for the stakingAddress1
STAKING_ADDRESS=$( sap-cli getaddressesbyaccount "stakingAddress1" )
sleep 3
echo -e "\n\n\033[0;32mA new address for staking is created:\n\033[0m$STAKING_ADDRESS\n\n"

echo -e "\n\n\033[0;34mPlease send some coins to the address above to start staking\n\033[0m"
