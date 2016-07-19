システム情報
============
OS
--
*   **Ubuntu 14.04.3 LTS**  
    [Boxcutter](https://github.com/boxcutter/ubuntu) を用いて作成しています。

ユーザーアカウント
------------------
*   **ユーザー:** pocci
*   **パスワード:** pocci

主なディレクトリ
----------------
```
/
  - root/
    - scripts/      ... プロビジョニング処理用スクリプト
  - user_data/      ... Vagrant 共有フォルダ (Synced Folder)
  - opt/
    - pocci-box/
      - pocci/      ... ${POCCI_DIR} (Pocci本体)
      - scripts/    ... ${RUNTIME_SCRIPTS_DIR} (運用スクリプト)
      - backup/     ... ${BACKUP_DIR} (バックアップデータ格納先)
        - daily/    ... 日次バックアップデータ格納場所
        - timely/   ... 時間指定バックアップデータ格納場所
```

プロビジョニング処理
--------------------
**/root/scripts/setup.sh** を実行することにより、
プロビジョニング処理が行われます。

*   /root/scripts/setup.sh の実行は、
    [デフォルトのVagrantファイル](./default-vagrantfile.ja.md)
    に定義されています。
*   /root/scripts/setup.sh は最初に `/user_data/environment.sh` を呼び出し、
    その後 /root/scripts/setup-*.sh を順次呼び出して処理実行します。
*   `environment.sh` の記述内容については、
    [environment.shについて](./environment.ja.md)を参照してください。


シェル初期化スクリプト
----------------------
プロビジョニング処理の際 **/etc/profile.d/** ディレクトリ内に
**pocci.sh** と **proxy.sh** が作成されます。

これらのファイルは、ログインシェルおよび cron
ジョブ開始時に読み込まれて環境変数設定を行います。

### /etc/profile.d/pocci.sh:
変数                | 設定される値
------------------- | ------------------------------
POCCI_BOX_DIR       | /opt/pocci-box
RUNTIME_SCRIPTS_DIR | /opt/pocci-box/scripts
POCCI_DIR           | /opt/pocci-box/pocci
KANBAN_REPOSITORY   | /opt/pocci-box/kanban/.git
BACKUP_DIR          | /opt/pocci-box/backup
POCCI_USER          | pocci
NOTIFIER            | environment.sh の notifier
DAILY_BACKUP_NUM    | environment.sh の daily_backup_num
BACKUP_TYPE         | environment.sh の backup_type
BACKUP_SERVER       | environment.sh の backup_server
BACKUP_SERVER_USER  | environment.sh の backup_server_user
BACKUP_SERVER_DIR   | environment.sh の backup_server_dir
ON_STARTUP_FINISHED | environment.sh の on_startup_finished
POCCI_TEMPLATE      | environment.sh の template
ADMIN_MAIL_ADDRESS  | environment.sh の admin_mail_address
ALERT_MAIL_FROM     | environment.sh の alert_mail_from

### /etc/profile.d/proxy.sh:
変数        | 設定される値
----------- | ------------------------------
http_proxy  | environment.sh の http_proxy
https_proxy | environment.sh の https_proxy / http_proxy
ftp_proxy   | environment.sh の ftp_proxy / http_proxy
rsync_proxy | environment.sh の rsync_proxy / http_proxy
no_proxy    | environment.sh の no_proxy / http_proxy


cron (定期実行ジョブ設定)
-------------------------
プロビジョニング処理により、
以下のスクリプトの定期実行が pocci ユーザーの crontab に登録されます。

*   **${RUNTIME_SCRIPTS_DIR}/do-backup daily:** デイリーバックアップ
*   **${RUNTIME_SCRIPTS_DIR}/do-backup:** 時間指定バックアップ
*   **${RUNTIME_SCRIPTS_DIR}/watch-docker-process:** Dockerプロセスの生存チェック
*   **${RUNTIME_SCRIPTS_DIR}/watch-disk-usage:** ディスク空き容量チェック

pocci ユーザーで `crontab -l` を実行すれば現在の設定内容が確認でき、
`crontab -e` コマンドにより設定編集が可能です。

実行例:
```bash
$ crontab -l
MAILTO=""
0 0 * * * /opt/pocci-box/scripts/do-backup daily
0 10,12,18 * * * /opt/pocci-box/scripts/do-backup
11 * * * * /opt/pocci-box/scripts/watch-docker-process
12 * * * * /opt/pocci-box/scripts/watch-disk-usage
```


CIサービスの自動起動
--------------------
**${RUNTIME_SCRIPTS_DIR}/start** が
pocci サービスとしてOS起動時に自動起動します。  
*   ${RUNTIME_SCRIPTS_DIR}/start
    は **${POCCI_DIR}/bin/up-service**
    を呼び出しています。
*   pocci サービスの自動起動は **/etc/init/pocci.conf**
    で設定されています。


公開ポート
----------
[デフォルトのVagrantファイル](./default-vagrantfile.ja.md)
の定義により、VM内の以下のポートがホスト側のポートとして公開されます。

ポート番号    | 役割
------------- | -------------------------------------
22            | システム管理用 SSH ポート
80            | 各種CIサービスのWebインターフェース
389           | LDAPサービス
10022         | GitLab用 SSH ポート
10050         | Zabbix エージェント
50000         | Jenkins スレーブ接続用ポート


定期バックアップ
----------------
簡易的な定期バックアップの仕組みを備えています。

### バックアップ対象
以下のデータを対象にしています。

*   ${POCCI_DIR}/config 内の設定データ
*   標準のDockerコンテナが扱うデータの中で以下に該当するもの
    *   Dockerfile または ${POCCI_DIR}/config/*.yml でvolume指定されているディレクトリ
        の中でマウント設定されていないもの

    実際にどのディレクトリが上記に該当するかを確かめるには、
    `cd ${POCCI_DIR}/bin/; . pocci-utils; vls` を実行してください。  
    ここで表示されたディレクトリの末尾が **/_data** になっているものが
    バックアップ対象になります。


### バックアップの種類
「デイリーバックアップ」と「時間指定バックアップ」
の2種類が存在します。

バックアップ対象のデータはどちらも同じですが、
起動タイミングとデータの保管方法が若干異なります。

#### 時間指定バックアップ
数時間おきに起動するバックアップ処理です。
バックアップデータは **${BACKUP_DIR}/timely/**
ディレクトリに保管されます。

#### デイリーバックアップ
一日一回起動するバックアップ処理です。
バックアップデータは **${BACKUP_DIR}/daily/**
ディレクトリに保管されます。

デイリーバックアップ処理が正常終了すると、
**${BACKUP_DIR}/timely/**
ディレクトリ内のバックアップデータは全て削除されます。

また、古いデイリーバックアップデータもこのタイミングで削除されます。

*   バックアップデータをいくつ保持しておくかについては、以下の方法で設定できます。
    *   **VM作成前:** environment.sh の `daily_backup_num`
    *   **VM作成後:** /etc/profile.d/pocci.sh の `DAILY_BACKUP_NUM`


#### 実行タイミング設定

バックアップの実行タイミングは pocci ユーザーの crontab で指定されています。  
`crontab -l` を実行すると、
現在設定されているバックアップ実行タイミングを確認できます。

実行例:
```
$ crontab -l
MAILTO=""
0 0 * * * /opt/pocci-box/scripts/do-backup daily
0 10,12,18 * * * /opt/pocci-box/scripts/do-backup
...
```

最初の行 (末尾が **daily** の行) がデイリーバックアップ、
次の行が時間指定バックアップの設定になります。

上記の例では、デイリーバックアップが **00:00**、
時間指定バックアップが **10:00**、**12:00**、**18:00**
に実行されている設定になっています。

`crontab -e` コマンドで設定の変更が可能です。
*   VM作成時に上記の設定を行いたい場合は、
    environment.sh の中で
    `daily_backup_hour` (デイリーバックアップ) および
    `timely_backup_hour` (時間指定バックアップ) を
    設定してください。


#### 注意事項

*   定期バックアップは、サービスを停止せずに行われるため、
    実行タイミングによっては不整合な（正常に復元できない）
    データとなる可能性もあります。  
    この状況を回避するため、デイリーバックアップの実行時間は
    できるだけ利用者がいない時間帯を設定することをおすすめします。
*   このバックアップはあくまでも簡易的なものであり、
    データの復元を完全に保証するものではありません。
    本格的なシステム運用を行いたい場合は、
    他のデータ保証手段を併用することをお勧めします。


### バックアップデータの保管場所
バックアップデータは **${BACKUP_DIR}** ディレクトリに保管されます。

environment.sh で `export backup_type=rsync` を指定して VM 作成した場合、
別マシンに rsync で ${BACKUP_DIR} ディレクトリの同期 (転送) を行います。

転送先指定は、
VM作成前であれば environment.sh (backup_server, backup_server_user, backup_server_dir)、
VM作成後の場合は /etc/profile.d/pocci.sh (BACKUP_SERVER, BACKUP_SERVER_USER, BACKUP_SERVER_DIR)
で指定できます。

rsync を実行するためには、事前にキーペアを作成し、
転送先の authorized_keys に公開キーを追加しておく必要があります。

キーペアの作成例:
```bash
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
```

公開キーの追加例:
```
ssh ${BACKUP_SERVER_USER}@${BACKUP_SERVER} "cat >>~/.ssh/authorized_keys" <~/.ssh/id_rsa.pub
```


### リストア方法
バックアップデータからの復元は以下の手順で実施できます。

#### Step1 定期バックアップの停止
リストア作業中にバックアップ処理が動作することを防止するために、
crontab を編集して定期バックアップを停止してください。

#### Step2 バックアップデータの確認
1.  `ls -R ${BACKUP_DIR}/*` を実行し、ファイルが存在するかどうかを確認する。
1.  ファイルが存在しない場合は **Step3 バックアップデータの取得**に、
    ファイルが存在する場合は、**Step4 リストアの実施**に進む。

#### Step3 バックアップデータの取得
1.  `${RUNTIME_SCRIPTS_DIR}/pull-backup-files` を実行して、バックアップ先サーバからバックアップデータを取得する。
1.  上記のコマンドが失敗する場合、バックアップ先サーバに存在するバックアップファイル (日付-時間.tar.gz) を
    `${BACKUP_DIR}/timely/` に手動でコピーする。
1.  以下のコマンドを実行してバックアップファイルを確認する（**日付-時間.tar.gz** というファイル名になっている）。

    ```bash
    ls -R ${BACKUP_DIR}/*
    ```

#### Step4 リストアの実施
1.  以下のコマンドを実行してバックアップファイルを `${POCCI_DIR}/backup` に展開する。

    ```bash
    mkdir ${POCCI_DIR}/backup
    cd ${POCCI_DIR}/backup
    tar xvfz ${BACKUP_DIR}/[timelyもしくはdaily]/日付-時間.tar.gz
    ```

1.  以下のコマンドを実行してリストアを実行する。

    ```bash
    cd ${POCCI_DIR}/bin
    ./restore ../backup/日付-時間/
    ```


システム状態通知機能
--------------------
**ディスク容量不足**、**Dockerプロセス停止**、
**バックアップ失敗**の際に通知を行う機能があります。

この通知は environment.sh の **notifier**
での指定方法に従って行われます。

### notifier=mail (あるいはnotifier指定なし) の場合
environment.sh の **admin_mail_address**
で指定されたメールアドレスに行われます。

### notifier=zabbix の場合
environment.sh の **zabbix_server** で指定された
IPアドレスのZabbix Serverに対して zabbix_sender で通知を行います。

通知時のキーおよびメッセージは以下の通りです。

通知内容            | キー                  | メッセージ(正常時)  | メッセージ(正常時)
------------------- | --------------------- | ------------------- | -------------------
ディスク容量不足    | pocci.disk.usage      | 0:Disk Usage:n%     | 1:Disk Usage:n%
Dockerプロセス停止  | pocci.docker.process  | 0:OK                | 2:Exit: ...
バックアップ失敗    | pocci.backup          | 0:Backup OK         | 2:Backup Error: ...


メール送信
----------
**sSMTP**によるメール送信機能を備えています。

プロビジョニング処理では、sSMTP (`/etc/ssmtp/ssmtp.conf`) に対して以下の設定を行っています。
*   environment.sh の smtp_relayhost に従ってメール転送先SMTPサーバを設定。
    smtp_relayhost が指定されていない場合は localhost 上のSMTPサーバ (smtpサービス) を利用。
*   environment.sh の smtp_password が指定されている場合 SMTP 認証設定を追加

上記設定の詳細内容は `/root/scripts/setup-mail.sh` で確認できます。

また、environment.sh の smtp_relayhost, smtp_password の設定により、
それぞれ環境変数 `SMTP_RELAYHOST`, `SMTP_PASSWORD` が設定されます。
これにより、Pocciのsmtpサービス(Postfix)に関しても、メール転送先およびSMTP認証の設定が行われます。
