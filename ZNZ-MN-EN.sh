#!/bin/bash
#please do this script as root.
######################################################################
#オプションの判定処理
while :
do
  case "$1" in
    -v | --version)
    version="$2" #get version data
    shift 2
    ;;
    -u | --update)
    install=0
    update=1
    shift
    ;;
    -i | --install)
    install=1
    update=0
    shift
    ;;
    -g | --generate)
    generate=1
    shift
    ;;
    -*)
    echo "Error: Invalid option:  $1" > $2
    exit 1
    ;;
    *)
    break
    ;;
  esac
done

# Generate masternode private key
function generate_privkey() {
  mkdir -p /etc/masternodes/
  echo -e "rpcuser=test\nrpcpassword=passtest" >> /etc/masternodes/zenzo_test.conf
  zenzod -daemon -conf=/etc/masternodes/zenzo_test.conf -datadir=/etc/masternodes >> mn.log
  sleep 5
  mngenkey=$(zenzo-cli -conf=/etc/masternodes/zenzo_test.conf -datadir=/etc/masternodes masternode genkey)
  zenzo-cli -conf=/etc/masternodes/zenzo_test.conf -datadir=/etc/masternodes stop >> mn.log
  sleep 5
  rm -r /etc/masternodes/
}

# Make masternode.conf for ppl
function create_mnconf() {
  echo ZNZ-MN01 $ipaddress:26210 $mngenkey TRANSACTION_ID TRANSACTION_INDEX >> tmp_masternode.conf
  cat tmp_masternode.conf
}
echo " "
echo "*********** Welcome to the ZENZO (ZNZ) Masternode Setup Script ***********"
echo 'This script will install all required updates & package for Ubuntu 16.04 !'
echo 'This script will install Zenzo masternode.'
echo 'You can run this script on VPS only.'
echo '****************************************************************************'
echo '*** Installing package ***'
apt-get update -qqy
apt-get upgrade -qqy
apt-get dist-upgrade -qqy
apt-get install -qqy nano htop git wget
echo '*** Step 2/4 ***'
echo '*** Configuring firewall ***'
apt-get install -qqy ufw
ufw allow ssh/tcp >> mn.log
ufw limit ssh/tcp >> mn.log
ufw allow 26210/tcp >> mn.log
ufw logging on >> mn.log
ufw --force enable >> mn.log
ufw status >> mn.log
zenzo-cli stop &>> mn.log
./zenzo-cli stop &>> mn.log
echo '*** Step 3/4 ***'
if [ -e /usr/local/bin/zenzod -o -e zenzod ]; then
  echo '***Backup your existing zenzod. If you want to restore, please check ZENZO_DATE ***'
  mkdir ZENZO_`date '+%Y%m%d'` >> mn.log
  mv /usr/local/bin/zenzod /usr/local/bin/zenzo-cli /usr/local/bin/zenzo-tx ~/ZENZO_`date '+%Y%m%d'` &>> mn.log
  mv ~/zenzod ~/zenzo-cli ~/zenzo-tx ~/ZENZO_`date '+%Y%m%d'` &>> mn.log
fi

echo '*** Step 4/4 ***'
echo '***Installing zenzo wallet daemon***'
curl -sc /tmp/cookie "https://drive.google.com/uc?export=download&id=13QrHlxAnPcsVWeHQHmQHzW43cC49PrN0" > /dev/null
CODE="$(awk '/_warning_/ {print $NF}' /tmp/cookie)"
curl -Lb /tmp/cookie "https://drive.google.com/uc?export=download&confirm=${CODE}&id=13QrHlxAnPcsVWeHQHmQHzW43cC49PrN0" -o znz.zip
# wget -nv https://github.com/zenzoproject/Zenzo/releases/download/v${version}/zenzo-${version}-x86_64-linux-gnu.tar.gz >> mn.log
# tar -xvzf zenzo-${version}-x86_64-linux-gnu.tar.gz >> mn.log
# version=${version:0:5}
# cd zenzo-${version}/bin
# mv zenzo* /usr/local/bin/
unzip znz.zip
cd
cd znz/Linux/
mv zenzo* /usr/local/bin/
# rm zenzo-${version}-x86_64-linux-gnu.tar.gz
# rm -r zenzo-${version}
cd
rm -r znz.zip znz
if [ $update -eq 1 ]; then
  echo "Updating"
  zenzod -daemon
  zenzo-cli getinfo
  echo "Finish Updating"
  echo "Check version data."
  echo "After checking, please restart Zenzo masternode from zenzo-qt"
  echo "***End***"
elif [ $install -eq 1 ]; then
  echo '*** Install and configuring masternode settings ***'
  mkdir .zenzo
  rpcusr=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 20 | head -1)
  rpcpass=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 20 | head -1)
  ipaddress=$(curl -s inet-ip.info)
  if [ $generate -eq 1 ]; then
    generate_privkey
  else
    echo "Enter or paste masternode private key"
    read mngenkey
    while [ ${#mngenkey} -ne 51 ]
    do
      echo "Invalid masternode private key. please reinput."
      read mngenkey
    done
  fi
  echo -e "rpcuser=$rpcusr\nrpcpassword=$rpcpass\nrpcallowip=127.0.0.1\nlisten=1\nserver=1\ndaemon=1\nstaking=0\nmasternode=1\nlogtimestamps=1\nmaxconnections=256\nexternalip=$ipaddress\nbind=$ipaddress\nmasternodeaddr=$ipaddress:26210\nmasternodeprivkey=$mngenkey\nenablezeromint=0\naddnode=67.23.158.129\naddnode=207.246.95.9\naddnode=140.82.61.65\naddnode=196.52.39.21\naddnode=149.28.98.180\naddnode=149.28.236.13\n" > ~/.zenzo/zenzo.conf
  echo '*** Start syncing ***'
  zenzod -daemon &>> mn.log
  echo 'After 10sec, I will show you the outputs of getinfo'
  sleep 10
  zenzo-cli getinfo
  echo 'After fully syncing, you can start Zenzo masternode.'
  echo 'There is example line for masternode.conf. Please copy this line and paste to your masternode.conf'
  echo " "
  create_mnconf
  echo " "
  echo 'You can check the line by entering  **cat tmp_masternode.conf** '
else
  echo "Invalid command, or argument. If you want to update, use '-u', to install, use '-i'."
　echo "**END**"
fi
