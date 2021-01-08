#!/bin/bash

#########################################################################################
#											#
# This script assumes that the user is root and the shell is at root's home		#
#											#
#											#
# This script takes arguments for coin type and it's properties.			#
# Arguments:										#
# $1: Node ID (Example: Sapphire01, Jackpot01, Aezora01 etc.)				#
# $2: Path to the JSON file that holds COIN properties (Example: /root/sapphire.json)	#
#											#
#########################################################################################

# Clear the screen
clear

# Install required softares
echo -e "\033[0;34m### Installing required packages\033[0m\n"
sudo apt install wget zip unzip jq curl -y

# Set parameters to variables
ID=$1
COIN_PROPERTIES_FILE_PATH=$2

# Get COIN properties
NAME=$( cat $( echo $COIN_PROPERTIES_FILE_PATH ) | jq ".Name" )
SHORT_NAME=$( cat $( echo $COIN_PROPERTIES_FILE_PATH ) | jq ".CodeName" )
DESCRIPTION=$( cat $( echo $COIN_PROPERTIES_FILE_PATH ) | jq ".Description" )
TICKER=$( cat $( echo $COIN_PROPERTIES_FILE_PATH ) | jq ".Ticker" )
LATEST_VERSION=$( cat $( echo $COIN_PROPERTIES_FILE_PATH ) | jq ".LatestVersion" )
DAEMON=$( cat $( echo $COIN_PROPERTIES_FILE_PATH ) | jq ".Daemon" )
CLI=$( cat $( echo $COIN_PROPERTIES_FILE_PATH ) | jq ".Cli" )
TX=$( cat $( echo $COIN_PROPERTIES_FILE_PATH ) | jq ".Tx" )
QT=$( cat $( echo $COIN_PROPERTIES_FILE_PATH ) | jq ".Qt" )
DATA_DIR=$( cat $( echo $COIN_PROPERTIES_FILE_PATH ) | jq ".DataDirectory" )
CONF_NAME=$( cat $( echo $COIN_PROPERTIES_FILE_PATH ) | jq ".ConfName" )
PID_NAME=$( cat $( echo $COIN_PROPERTIES_FILE_PATH ) | jq ".PidName" )

# Get bootstrap and latest released binaries links and zip-file names
BOOTSTRAP_LINK=$( cat $( echo $COIN_PROPERTIES_FILE_PATH ) | jq ".Bootstrap" )
BINARIES_LINK=$( cat $( echo $COIN_PROPERTIES_FILE_PATH ) | jq ".Binaries" )
BOOTSTRAP_NAME=$( echo $BOOTSTRAP_LINK | awk -F'/' '{ print $NF }' )
BINARIES_NAME=$( echo $BINARIES_LINK | awk -F'/' '{ print $NF }' )

# Create directory for binaries zip file and bootstrap.zip and change directory to it
mkdir tmp
cd tmp

# Download coin latest binaries and extract them
echo -e "\n\033[0;34m### Downloading coin's latest binaries and installing them\033[0m\n"
wget $BINARIES_LINK
unzip $BINARIES_NAME

# Install coin latest binaries to /usr/local/bin and create data directory under home directory
sudo mv $DAEMON $CLI $TX $QT /usr/local/bin/
mkdir $HOME/$DATA_DIR

# Download bootstrap and extract it into coin data directory
echo -e "\n\033[0;34m### Downloading bootstrap and extracting it into data directory\033[0m\n"
wget $BOOTSTRAP_LINK
unzip -q $BOOTSTRAP_NAME -d $HOME/$DATA_DIR

# Change directory to $HOME and remove tmp directory
cd $HOME
rm -fr tmp

# Install blocknotify.sh script
sudo curl -sL https://raw.githubusercontent.com/pedro-at-decenomy/seed_scripts/master/blocknotify.sh > /usr/local/bin/blocknotify.sh
chmod +x /usr/local/bin/blocknotify.sh

# Run blocknotify once
#/usr/local/bin/blocknotify.sh $ID $TICKER $CLI

# Create empty coin configuration file and fill it with arguments
echo -e "\n\033[0;34m### Creating $CONF_NAME and populating it\033[0m\n"

touch $HOME/$DATA_DIR/$CONF_NAME
echo "daemon=1" >> $HOME/$DATA_DIR/$CONF_NAME
echo "server=1" >> $HOME/$DATA_DIR/$CONF_NAME
echo "addnode=seed1.sappcoin.com" >> $HOME/$DATA_DIR/$CONF_NAME
echo "addnode=seed2.sappcoin.com" >> $HOME/$DATA_DIR/$CONF_NAME
echo "addnode=seed3.sappcoin.com" >> $HOME/$DATA_DIR/$CONF_NAME
echo "addnode=seed4.sappcoin.com" >> $HOME/$DATA_DIR/$CONF_NAME
echo "addnode=seed5.sappcoin.com" >> $HOME/$DATA_DIR/$CONF_NAME
echo "addnode=seed6.sappcoin.com" >> $HOME/$DATA_DIR/$CONF_NAME
echo "addnode=seed7.sappcoin.com" >> $HOME/$DATA_DIR/$CONF_NAME
echo "addnode=seed8.sappcoin.com" >> $HOME/$DATA_DIR/$CONF_NAME
echo "banaddressmempool=SfFQ3twBcziZAHMeULnrDSemaqZqHUpmj4" >> $HOME/$DATA_DIR/$CONF_NAME
echo "banaddressmempool=SPixuKa8Vnyi6RpcB8XTXh7TBqq6TqZ43b" >> $HOME/$DATA_DIR/$CONF_NAME
#echo "alertnotify=echo %s | mail -s \"Kyanite-testnet alert!\" bedriguler@gmail.com" >> $HOME/$DATA_DIR/$CONF_NAME
#echo "walletnotify=echo %s | mail -s \"Kyanite-testnet alert!\" bedriguler@gmail.com" >> $HOME/$DATA_DIR/$CONF_NAME
echo "blocknotify=/usr/local/bin/blocknotify.sh $ID SAPP $CLI" >> $HOME/$DATA_DIR/$CONF_NAME


# Install as a service
sudo cat << EOF > /etc/systemd/system/$SHORT_NAME.service
[Unit]
Description=$DESCRIPTION service
After=network.target
[Service]
User=root
Group=root
Type=forking
ExecStart=/usr/local/bin/$DAEMON -daemon -conf=/$HOME/$DATA_DIR/$CONF_NAME -datadir=/$HOME/$DATA_DIR
ExecStop=-/usr/local/bin/$CLI -conf=/$HOME/$DATA_DIR/$CONF_NAME -datadir=/$HOME/$DATA_DIR stop
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl start $SHORT_NAME.service
sudo systemctl enable $SHORT_NAME.service >/dev/null 2>&1

# Start coin daemon
echo -e "\n\033[0;34m### Running the daemon. Please wait.\033[0m\n"

# Wait 5 seconds for the daemon starts
sleep 5

watch /usr/local/bin/$CLI -conf=/root/$DATA_DIR/$CONF_NAME -datadir=/root/$DATA_DIR getinfo
