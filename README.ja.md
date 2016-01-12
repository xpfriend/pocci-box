pocci-box
=========

[Pocci](https://github.com/xpfriend/pocci) の [Vagrant box](https://atlas.hashicorp.com/xpfriend/boxes/pocci).

[English](./README.md)

必須環境
--------
*   起動するVMに4GB以上割り当て可能な空きメモリをもつマシン
*   VirtualBox
*   Vagrant

使い方
------
1.  Vagrantfile を作成する:

    ```bash
    vagrant init -m xpfriend/pocci
    ```

2.  (必要に応じて) Vagrantfile を修正する:

    ```ruby
    Vagrant.configure("2") do |config|
        config.vm.box = "xpfriend/pocci"

        config.vm.provider "virtualbox" do |v|
            v.customize ["modifyvm", :id, "--memory", 8192]
            v.customize ["modifyvm", :id, "--cpus", 4]
        end
    end
    ```
    
3.  プロキシサーバ利用環境にある場合、
    Vagrantfile と同じディレクトリに `environment.sh` という名前でファイルを作成して、
    以下のように環境変数設定を行ってください:

    ```bash
    export http_proxy=http://proxy.example.com:8080/
    ```

    environment.sh はプロビジョニング時に利用される設定ファイルです。
    プロキシサーバ以外にも、OSのタイムゾーンやCIサービスの構成などを設定できます。

4.  VM を起動して気長に :coffee: 待てば CI 関連サービスが利用できるようになります。

    ```bash
    vagrant up
    ```

    利用方法については、[Pocci](https://github.com/xpfriend/pocci) を参照してください。


デフォルトの Vagrantfile
------------------------
デフォルトの Vagrantfile は以下の設定になっています。

```ruby
Vagrant.configure("2") do |config|
    config.vm.box = "xpfriend/pocci"
    config.ssh.username = "pocci"
    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.synced_folder ".", "/user_data"

    config.vm.network "forwarded_port", guest: 22, host: 22, id: "ssh"
    config.vm.network "forwarded_port", guest: 80, host: 80, id: "http"
    config.vm.network "forwarded_port", guest: 389, host: 389, id: "ldap"
    config.vm.network "forwarded_port", guest: 443, host: 443, id: "https"
    config.vm.network "forwarded_port", guest: 10022, host: 10022, id: "git"
    config.vm.network "forwarded_port", guest: 50000, host: 50000, id: "jenkins_slave_agent"

    config.vm.provider :virtualbox do |v, override|
        v.customize ["modifyvm", :id, "--memory", 4096]
        v.customize ["modifyvm", :id, "--cpus", 2]
    end

    config.vm.graceful_halt_timeout = 120
    config.vm.provision "shell", inline: "/usr/bin/sudo /root/scripts/setup.sh"
end
```

environment.sh
--------------
environment.sh には以下の設定が可能です。

変数名          | 設定する値                      | デフォルト値             | 記述例
--------------- | ------------------------------- | ------------------------ | -------------------------------------------------
http_proxy      | http利用時のプロキシサーバURL   | なし                     | export http_proxy=http://proxy.example.com:8080/
https_proxy     | https利用時のプロキシサーバURL  | http_proxyに設定された値 | export https_proxy=http://proxy.example.com:8080/
ftp_proxy       | ftp利用時のプロキシサーバURL    | http_proxyに設定された値 | export ftp_proxy=http://proxy.example.com:8080/
rsync_proxy     | rsync利用時のプロキシサーバURL  | http_proxyに設定された値 | export rsync_proxy=http://proxy.example.com:8080/
no_proxy        | プロキシを経由せずに接続するホストの名前またはアドレス。カンマ区切りで複数指定可 | 127.0.0.1,localhost | export no_proxy="127.0.0.1,localhost,my-server"
timezone        | タイムゾーン                    | Etc/UTC                  | export timezone=Asia/Tokyo
smtp_relayhost  | メール送信先(Postfix設定)       | なし                     | export smtp_relayhost=[smtp.example.com]:587
smtp_password   | SMTP認証情報(Postfix設定)       | なし                     | export smtp_password=user:password
admin_mail_address | システム管理者メールアドレス | pocci@localhost.localdomain | export admin_mail_address=admin@example.com
alert_mail_from | アラート通知メールのFrom        | admin_mail_addressの値   | export alert_mail_from=pocci@example.com
daily_backup_num | デイリーバックアップの保持数   | 2                        | export daily_backup_num=7
daily_backup_hour | デイリーバックアップの起動時間(0-23) | 0                 | export daily_backup_hour=1
timely_backup_hour | 時間指定バックアップの起動時間(0-23)。カンマ区切りで複数指定可能 | 10,12,18 | export timely_backup_hour=2,19
backup_type | リモートバックアップのタイプ | なし | export backup_type=rsync
backup_server | バックアップ先サーバ。backup_type=rsyncを指定した場合に設定する | なし | export backup_server=backup.example.com
backup_server_user | バックアップ先サーバへのログインユーザー。backup_type=rsyncを指定した場合に設定する | なし | export backup_server_user=user01
backup_server_dir | バックアップ先サーバ上のバックアップデータ格納先ディレクトリ。backup_type=rsyncを指定した場合に設定する | なし | export backup_server_dir=/work/backup
on_provisioning_finished | 初期設定完了直後に実行するコマンド | なし         | export on_provisioning_finished="echo OK"
on_startup_finished | Pocciサービス起動直後に実行するコマンド | "echo Done"  | export on_startup_finished="echo Started"
service_type    | サービス構成タイプ              | default                  | export service_type=redmine


### service_type  (サービス構成タイプ) の設定について
*   service_type を指定しない、もしくは default を指定した場合:  
    初回起動時に `${POCCI_DIR}/bin/create-config default;${POCCI_DIR}/bin/up-service` が実行されます。
*   service_type に jenkins を指定した場合:  
    初回起動時に `${POCCI_DIR}/bin/create-config jenkins;${POCCI_DIR}/bin/up-service` が実行されます。
*   service_type に redmine を指定した場合:  
    初回起動時に `${POCCI_DIR}/bin/create-config redmine;${POCCI_DIR}/bin/up-service` が実行されます。
*   service_type に default / jenkins / redmine 以外を指定し、Vagrantfile と同じディレクトリに `setup.[サービス構成タイプ].yml` ファイルを作成した場合:  
    初回起動時に `${POCCI_DIR}/bin/create-config [サービス構成タイプ];${POCCI_DIR}/bin/up-service` が実行されます。
*   service_type に default / jenkins / redmine 以外を指定し、Vagrantfile と同じディレクトリに `setup.[サービス構成タイプ].yml` ファイルを作成しなかった場合:  
    `create-config` や `up-service` は実行されません。VM 起動後に `setup.[サービス構成タイプ].yml` を編集し、
    手動で `create-config [サービス構成タイプ]`, `up-service` コマンドを実行してください。

### 注意事項
このファイルで設定された内容はプロビジョニング時 (初回起動時) のみ有効です。


システム情報
------------
### OS
*   **Ubuntu 14.04.3 LTS**  
    [Boxcutter](https://github.com/boxcutter/ubuntu) を用いて作成しています。

### ユーザーアカウント
*   **ユーザー:** pocci
*   **パスワード:** pocci

### ディレクトリ
```
/
  - user_data/      ... Vagrant 共有フォルダ (Synced Folder)
  - opt/
    - pocci-box/
      - pocci/      ... ${POCCI_DIR} (Pocci本体)
      - scripts/    ... ${RUNTIME_SCRIPTS_DIR} (運用スクリプト)
      - backup/     ... ${BACKUP_DIR} (バックアップデータ格納先)
```

### 自動起動
**${RUNTIME_SCRIPTS_DIR}/start** が
pocci サービスとしてOS起動時に自動起動します。  
${RUNTIME_SCRIPTS_DIR}/start
は **${POCCI_DIR}/bin/up-service**
を呼び出しています。