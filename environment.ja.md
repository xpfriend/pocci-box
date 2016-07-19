environment.shについて
======================

プロビジョニング処理 (/root/scripts/setup.sh) は処理開始時に environment.sh を呼び出します。  
environment.sh の中で環境変数を設定することにより、
プロビジョニング処理の動作をコントロールすることができます。

ここではプロビジョニング処理の動作に影響を及ぼす環境変数を説明します。

プロキシサーバ
--------------
### http_proxy, https_proxy, ftp_proxy, rsync_proxy
*   **設定内容:** プロキシサーバURL
*   **デフォルト値:**  
    *   **http_proxy:**  
        なし
    *   **https_proxy, ftp_proxy, rsync_proxy:**  
        http_proxy に設定された値。
        従って、すべてのプロトコルで同じURLのプロキシサーバを利用する場合は
        http_proxy のみを設定すればよい
*   **設定例:**

    ```bash
    export http_proxy=http://proxy.example.com:8080/
    ```

### no_proxy  
*   **設定内容:** プロキシを経由せずに接続するホストの名前またはアドレス。カンマ区切りで複数指定が可能
*   **デフォルト値:** 127.0.0.1,localhost
*   **設定例:**

    ```bash
    export no_proxy="127.0.0.1,localhost,my-server"
    ```

システム環境
------------
### domain
*   **設定内容:** ドメイン
*   **デフォルト値:** pocci.test
*   **設定例:**

    ```bash
    export domain=example.com
    ```

### timezone
*   **設定内容:** 以下2箇所のタイムゾーン設定を変更する  
    *   システムのタイムゾーン
    *   環境変数 `TZ`
*   **デフォルト値:** Etc/UTC
*   **設定例:**

    ```bash
    export timezone=Asia/Tokyo
    ```

### ntp_server
*   **設定内容:** NTPサーバー
    *   空白区切りで複数サーバ指定が可能
*   **デフォルト値:** なし
*   **設定例:**

    ```bash
    export ntp_server="ntp.nict.jp"
    ```


サービス構成
------------
### service_type
*   **設定内容:** サービス構成タイプもしくはセットアップファイル
*   **デフォルト値:** default
*   **設定例 (サービス構成タイプ指定):**

    ```bash
    export service_type=redmine
    ```

*   **設定例 (セットアップファイル相対パス指定):**

    ```bash
    export service_type=setup.redmine.yml
    ```

    *   テンプレート格納フォルダからの相対パスを指定する

*   **設定例 (セットアップファイル絶対パス指定):**

    ```bash
    export service_type=/user_data/setup.myservices.yml
    ```

*   **設定例 (セットアップファイルURL指定):**

    ```bash
    export service_type=http://example.com/setup.myservices.yml
    ```

### template
*   **設定内容:** テンプレート格納フォルダもしくはテンプレートを格納するgitリポジトリ
    *   **相対パスで指定された場合:**  
        ${POCCI_DIR} からの相対パスとみなされる
    *   **URL指定された場合:**  
        gitリポジトリとみなされる
    *   **空白区切りで複数指定された場合:**  
        より前に指定されたテンプレートがより後ろに指定されたテンプレートの内容で上書きされる
*   **デフォルト値:** template
*   **設定例 (フォルダ指定):**

    ```bash
    export template=/user_data/mytemplate
    ```

*   **設定例 (URL指定):**

    ```bash
    export template=http://example.com/mytemplate.git
    ```

*   **設定例 (複数指定):**

    ```bash
    export template="template /user_data/mytemplate"
    ```

### https
*   **設定内容:** https アクセスを行うかどうか。
*   **デフォルト値:** false
*   **設定例 (サービス構成タイプ指定):**

    ```bash
    export https=true
    ```

エラー通知
----------
### notifier
*   **設定内容:** エラー通知方法
*   **デフォルト値:** mail
*   **設定例:**

    ```bash
    export notifier=zabbix
    ```

### zabbix_server
*   **設定内容:** Zabbix ServerのIPアドレス。
    `notifier=zabbix` を指定した場合のみ有効。
*   **デフォルト値:** 127.0.0.1
*   **設定例:**

    ```bash
    export zabbix_server=192.168.0.10
    ```

メール送信
----------
### smtp_relayhost
    *   **設定内容:** メールを転送するSMTPサーバ。
*   **デフォルト値:** なし
*   **設定例:**

    ```bash
    export smtp_relayhost=[smtp.example.com]:587
    ```

### smtp_password
*   **設定内容:** SMTP認証情報。"ユーザーID:パスワード" の形式で指定する
*   **デフォルト値:** なし
*   **設定例:**

    ```bash
    export smtp_password=user:password
    ```

### admin_mail_address
*   **設定内容:** システム管理者のメールアドレス。以下3箇所の設定を行う
    *   pocci コンテナから参照される環境変数 ADMIN_MAIL_ADDRESS
    *   アラート通知メールの送信先
    *   ローカルホスト (localhost, localhost.localdomain, example.com, example.net) 宛てメール
*   **デフォルト値:** pocci@localhost.localdomain
*   **設定例:**

    ```bash
    export admin_mail_address=admin@example.com
    ```

### alert_mail_from
*   **設定内容:** アラート通知メールの送信元 (From) メールアドレス
*   **デフォルト値:** admin_mail_addressに設定した値
*   **設定例:**

    ```bash
    export alert_mail_from=pocci@example.com
    ```

バックアップ
------------
### daily_backup_num
*   **設定内容:** デイリーバックアップの保持数
*   **デフォルト値:** 2
*   **設定例:**

    ```bash
    export daily_backup_num=7
    ```

### daily_backup_hour
*   **設定内容:** デイリーバックアップの起動時間(0-23)
    *   デイリーバックアップを起動させない場合は "-" を指定する
*   **デフォルト値:** 0
*   **設定例:**

    ```bash
    export daily_backup_hour=1
    ```

### timely_backup_hour
*   **設定内容:** 時間指定バックアップの起動時間(0-23)。カンマ区切りで複数指定可能
    *   時間指定バックアップを起動させない場合は "-" を指定する
*   **デフォルト値:** 10,12,18
*   **設定例:**

    ```bash
    export timely_backup_hour=2,19
    ```

### backup_type
*   **設定内容:** リモートバックアップのタイプ
*   **デフォルト値:** なし
*   **設定例:**

    ```bash
    export backup_type=rsync
    ```

### backup_server
*   **設定内容:** バックアップ先サーバ。backup_type=rsyncを指定した場合に設定する
*   **デフォルト値:** なし
*   **設定例:**

    ```bash
    export backup_server=backup.example.com
    ```

### backup_server_user
*   **設定内容:** バックアップ先サーバへのログインユーザー。backup_type=rsyncを指定した場合に設定する
*   **デフォルト値:** なし
*   **設定例:**

    ```bash
    export backup_server_user=user01
    ```

### backup_server_dir
*   **設定内容:** バックアップ先サーバ上のバックアップデータ格納先ディレクトリ。backup_type=rsyncを指定した場合に設定する
*   **デフォルト値:** なし
*   **設定例:**

    ```bash
    export backup_server_dir=/work/backup
    ```

フックコマンド
--------------
### on_provisioning_finished
*   **設定内容:** プロビジョニング処理終了時に実行するコマンド
*   **デフォルト値:** なし
*   **設定例:**

    ```bash
    export on_provisioning_finished="echo OK"
    ```

### on_startup_finished
*   **設定内容:** Pocciサービス起動直後に実行するコマンド
*   **デフォルト値:** "echo Done"
*   **設定例:**

    ```bash
    export on_startup_finished="echo Started"
    ```

その他
------
environment.sh は通常のシェルスクリプトとして実行されるため、
上記の環境変数設定以外の処理を行うことも可能です。
