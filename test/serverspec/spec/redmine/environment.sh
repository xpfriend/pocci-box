export timezone=Asia/Tokyo
export ntp_server="ntp.nict.jp ntp.ubuntu.com"

export daily_backup_num=3
export daily_backup_hour=1
export timely_backup_hour=2,19

export backup_type=rsync
export backup_server=localhost
export backup_server_user=user01
export backup_server_dir=/home/user01/backup

export service_type=redmine
export redmine_lang=ja

export on_startup_finished="touch /tmp/startup_finished.txt"
export on_provisioning_finished="touch /tmp/provisioning_finished.txt"

. /user_data/test-environment.sh
export smtp_relayhost=${test_smtp_relayhost}
export smtp_password=${test_smtp_password}
export admin_mail_address=${test_admin_mail_address}
export alert_mail_from=${test_alert_mail_from}
