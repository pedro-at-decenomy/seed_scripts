#!/bin/bash

#########################################################################################
#                                                                                       #
# This script assumes that the user is root and the shell is at root's home             #
#                                                                                       #
#                                                                                       #
# This script takes arguments for coin type and it's properties.                        #
# Arguments:                                                                            #
# $1: Node ID (Example: Sapphire01, Jackpot01, Aezora01 etc.)                           #
# $2: Path to the JSON file that holds COIN properties (Example: /root/sapphire.json)   #
#                                                                                       #
#########################################################################################

echo -e "\n\033[0;33m### Please enter node ID (Example: SAPP01)\033[0m\n"
read -e ID

# Install required softares
echo -e "\033[0;34m### Installing required packages\033[0m\n"
sudo apt install wget zip unzip jq curl -y

# Download and run generalized installation script
curl -sL https://raw.githubusercontent.com/pedro-at-decenomy/seed_scripts/master/install.sh > sapphire_install_tmp.sh
chmod +x sapphire_install_tmp.sh
./sapphire_install_tmp.sh $ID "sapphire.json"
rm -f ./sapphire_install_tmp.sh

watch /usr/local/bin/sap-cli -conf=/root/.sap/sap.conf -datadir=/root/.sap getinfo
