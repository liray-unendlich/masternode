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
    echo "エラー: 不明なオプションを入力しています: $1" > $2
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
echo "*********** Zenzo マスターノード設定スクリプトへようこそ ***********"
echo 'Ubuntu16.04に必要なパッケージをすべてインストールします。'
echo 'その後Zenzoのウォレットをコンパイルし、設定、実行します。'
echo '*****************************************************************'
echo '*** パッケージのインストール ***'
apt-get update -qqy
apt-get upgrade -qqy
apt-get dist-upgrade -qqy
apt-get install -qqy nano htop git wget unzip
echo '*** ステップ 2/4 ***'
echo '*** ファイアウォールの設定・スタートを行います。 ***'
apt-get install -qqy ufw
ufw allow ssh/tcp >> mn.log
ufw limit ssh/tcp >> mn.log
ufw allow 26210/tcp >> mn.log
ufw logging on >> mn.log
ufw --force enable >> mn.log
ufw status >> mn.log
zenzo-cli stop &>> mn.log
./zenzo-cli stop &>> mn.log
echo '*** ステップ 3/4 ***'
if [ -e /usr/local/bin/zenzod -o -e zenzod ]; then
  echo '***ウォレットのバックアップを取ります。必要な場合はホーム直下のZENZO_日付 ***'
  echo '***という名前のディレクトリにアクセスしてください。***'
  mkdir ZENZO_`date '+%Y%m%d'` >> mn.log
  mv /usr/local/bin/zenzod /usr/local/bin/zenzo-cli /usr/local/bin/zenzo-tx ~/ZENZO_`date '+%Y%m%d'` &>> mn.log
  mv ~/zenzod ~/zenzo-cli ~/zenzo-tx ~/ZENZO_`date '+%Y%m%d'` &>> mn.log
fi

echo '*** ステップ 4/4 ***'
echo '***zenzoウォレットのインストールを開始します。***'
wget -nv https://github.com/Zenzo-Ecosystem/Zenzo-Core/releases/download/v${version}/zenzo-${version}-gnu64.zip >> mn.log
unzip zenzo-${version}-gnu64.zip >> mn.log
# version=${version:0:5}
mv zenzo* /usr/local/bin/
rm zenzo-${version}-gnu64.zip
# rm -r zenzo-${version}
cd
if [ $update -eq 1 ]; then
  echo "アップデートを行います。"
  zenzod -daemon
  zenzo-cli getinfo
  echo "アップデートは完了しました。"
  echo "バージョンデータが新しくなっているかご確認ください。"
  echo "ご確認後、マスターノードをzenzo-qtから再起動させるのをお忘れなきようお願いいたします。"
  echo "***終了***"
elif [ $install -eq 1 ]; then
  echo '*** インストールとしてウォレットの起動・初期設定を行います。 ***'
  mkdir .zenzo
  rpcusr=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 20 | head -1)
  rpcpass=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 20 | head -1)
  ipaddress=$(curl -s inet-ip.info)
  if [ $generate -eq 1 ]; then
    generate_privkey
  else
    echo "マスターノードプライベートキー(ステップ2の結果)を入力もしくはペーストしてください。"
    read mngenkey
    while [ ${#mngenkey} -ne 51 ]
    do
      echo "入力されたプライベートキーは正しくありません。もう一度確認してください。"
      read mngenkey
    done
  fi
  echo -e "rpcuser=$rpcusr\nrpcpassword=$rpcpass\nrpcallowip=127.0.0.1\nlisten=1\nserver=1\ndaemon=1\nstaking=0\nmasternode=1\nlogtimestamps=1\nmaxconnections=256\nexternalip=$ipaddress\nbind=$ipaddress\nmasternodeaddr=$ipaddress:26210\nmasternodeprivkey=$mngenkey\nenablezeromint=0\naddnode=67.23.158.129\naddnode=207.246.95.9\naddnode=140.82.61.65\naddnode=196.52.39.21\naddnode=149.28.98.180\naddnode=149.28.236.13\n" > ~/.zenzo/zenzo.conf
  echo '*** 設定が完了しましたので、ウォレットを起動して同期を開始します。 ***'
  zenzod -daemon &>> mn.log
  echo '10秒後に getinfo コマンドの出力結果を表示します。'
  sleep 10
  zenzo-cli getinfo
  echo '同期が完了すれば、zenzo-qtのウォレットからマスターノードを実行できます！'
  echo '最後に、masternode.conf の例をお見せします。こちらをご利用ください。'
  echo " "
  create_mnconf
  echo " "
  echo 'コマンド cat tmp_masternode.conf を入力することで再度表示可能です。'
else
  echo "入力が間違っているようです。アップデートの場合: '-u', 新規インストールの場合: '-i'をオプションとしてください。"
　echo "終了します。"
fi
