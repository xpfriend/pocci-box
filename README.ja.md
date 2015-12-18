pocci-box
=========

[Pocci](https://github.com/xpfriend/pocci) の [Vagrant box](https://atlas.hashicorp.com/xpfriend/boxes/pocci).

[English](./README.md)

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
デフォルトの Vagrantfile では以下の設定になっています。

```ruby
Vagrant.configure("2") do |config|
    config.vm.box = "xpfriend/pocci"

    config.vm.network "forwarded_port", guest: 22, host: 22
    config.vm.network "forwarded_port", guest: 80, host: 80
    config.vm.network "forwarded_port", guest: 389, host: 389
    config.vm.network "forwarded_port", guest: 443, host: 443
    config.vm.network "forwarded_port", guest: 5432, host: 5432
    config.vm.network "forwarded_port", guest: 10022, host: 10022
    config.vm.network "forwarded_port", guest: 50000, host: 50000

    config.vm.provider :virtualbox do |v, override|
        v.customize ["modifyvm", :id, "--memory", 4096]
        v.customize ["modifyvm", :id, "--cpus", 2]
    end

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
service_type    | サービス構成タイプ              | default                  | export service_type=redmine

### service_type  (サービス構成タイプ) の設定について
*   service_type を指定しない、もしくは default を指定した場合:  
    初回起動時に `~/pocci/bin/create-config default;~/pocci/bin/up-service` が実行されます。
*   service_type に redmine を指定した場合:  
    初回起動時に `~/pocci/bin/create-config redmine;~/pocci/bin/up-service` が実行されます。
*   service_type に default / redmine 以外を指定し、Vagrantfile と同じディレクトリに `setup.[サービス構成タイプ].yml` ファイルを作成した場合:  
    初回起動時に `~/pocci/bin/create-config [サービス構成タイプ];~/pocci/bin/up-service` が実行されます。
*   service_type に default / redmine 以外を指定し、Vagrantfile と同じディレクトリに `setup.[サービス構成タイプ].yml` ファイルを作成しなかった場合:  
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
*   **ユーザー:** vagrant
*   **パスワード:** vagrant

### ディレクトリ
```
/home/vagrant/
  - pocci/      ... Pocci
  - scripts/    ... スクリプト
```

### 自動起動
**/home/vagrant/scripts/start** が
pocci サービスとしてOS起動時に自動起動します。  
/home/vagrant/scripts/start
は **/home/vagrant/pocci/bin/up-service**
を呼び出しています。