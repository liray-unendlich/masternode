# zenzo-masternode-automation
script of masternode setup. include updating.

this script helps your masternode setup, or update.
it supports automatic setup and update.

## In English

## What the script do?
1. Install package and configure firewall
2. Install zenzod, zenzo-cli, zenzo-tx
3. generate private key and run daemon

## How To Use
### Update
```
wget https://raw.githubusercontent.com/liray-unendlich/masternode/master/ZNZ-MN-EN.sh

bash ZNZ-MN-EN.sh -u
```
### Install
```
wget https://raw.githubusercontent.com/liray-unendlich/masternode/master/ZNZ-MN-EN.sh

bash ZNZ-MN-EN.sh -i -g
```

After the script, you will see a line like this
```
ZenzoMN1 192.22.111.192:11771 88xrxxxxxxxxxxxxxxxxxxxxxxx7K 6b4c9xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx7ee23 0
```

### Option
- -v | --version : set version
- -u | --update : update your client
- -i | --install : install client
- -g | --generate : generate private key in the script


## In Japanese
このスクリプトはマスターノードをセットアップ・アップデートしたい方用です。
自動的なセットアップ・アップデートを行います。
詳細なガイドは pivx-type-masternode-installation(Phore).pdf をご覧ください。
## やっていること
1. 各種パッケージ・アップデート
2. zenzod, zenzo-cli, zenzo-tx のダウンロード・インストール
3. プライベートキーの生成

## 使い方
### アップデート
```
wget https://raw.githubusercontent.com/liray-unendlich/masternode/master/ZNZ-MN-JP.sh

bash ZNZ-MN-JP.sh -u
```
一行ずつ

### インストール
```
wget https://raw.githubusercontent.com/liray-unendlich/masternode/master/ZNZ-MN-JP.sh

bash ZNZ-MN-JP.sh -i -g
```
一行ずつ

この場合すでにzenzo.confにはプライベートキーなどの必要情報が全て入力されているので、後はmasternode.confに入力するだけでマスターノードを作ることが出来ます。
スクリプトの最後に、masternode.confに入力する行が出ますので、コピーして入力後、トランザクションID, indexを編集しましょう。

## マスターノードのインストール方法
1. 15kZNZを1つのアドレスに送金(ちょうど)
2. 1確認の後、デバッグコンソールを開き
```
masternode outputs
```
を入力し、エンターキーを押す
3. 出力結果は
```
{
  "e758e1e33880d2cf99c7ac9ae51962149180df5de356283a69a43e4a0250d9d2": "0"
}
```
な感じで出ます。"トランザクションID": "index"の順番になっています。
このそれぞれを上のスクリプト実行後に出る
```
ZNZ-MN01 IPアドレス:26210 マスターノードプライベートキー TRANSACTION_ID TRANSACTION_INDEX
```
のTRANSACTION_ID, TRANSACTION_INDEXと置き換えて保存、zenzo-qtを再起動しマスターノードタブを開着ましょう。
するとZNZ-MN01という欄が新しく加わっているので、クリックした後エイリアスからスタートボタンを押しましょう。

### オプション説明
- -v | --version : バージョンを指定します。 ex. -v 1.2.2
- -u | --update : クライアントのアップデート ex. -u
- -i | --install : クライアントの新規インストール ex. -i
- -g | --generate : プライベートキーの発行 ex. -g
マスターノードを新規にインストールされる場合は -i オプションを
既存のマスターノードをアップデートする場合は -u オプションをご利用ください。
