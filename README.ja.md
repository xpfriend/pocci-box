pocci-box
=========

[Pocci](https://github.com/xpfriend/pocci) の [Vagrant box](https://atlas.hashicorp.com/xpfriend/boxes/pocci).

[English](./README.md)

必須環境
--------
*   起動するVMに5GB以上割り当て可能な空きメモリをもつマシン
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

    *   参考: [デフォルトのVagrantfile](./default-vagrantfile.ja.md)
    
3.  プロキシサーバ利用環境にある場合、
    Vagrantfile と同じディレクトリに `environment.sh` という名前でファイルを作成して、
    以下のように環境変数設定を行ってください:

    ```bash
    export http_proxy=http://proxy.example.com:8080/
    ```

    environment.sh はプロビジョニング (初期設定) 処理開始直後に読み込まれるスクリプトです。
    このスクリプトではプロキシサーバ以外にもOSのタイムゾーンやCIサービスの構成などの環境設定が行えます。
    詳細については [environment.shについて](./environment.ja.md)を参照してください。

4.  `vagrant up` を実行して気長に :coffee: 待てば CI 関連サービスが利用できるようになります。

    ```bash
    vagrant up
    ```

    *   CI関連サービスへの接続方法については、
        [サービスへの接続方法](https://github.com/xpfriend/pocci/blob/master/document/access.ja.md) を参照してください。
        *   hostsファイルに設定するIPアドレスについて
            *   `vagrant up` を実行したマシンのhostsファイルには、**127.0.0.1** を指定してください。
            *   その他のマシンのhostsファイルには、`vagrant up` を実行したマシンのIPアドレスを指定してください。
    *   CI関連サービスの利用方法全般については
        [CIサービス構築・利用手引き](https://github.com/xpfriend/pocci/blob/master/document/index.ja.md)
        を参照してください。
    *   VM 環境の詳細については[システム情報](./system-information.ja.md)を参照してください。
