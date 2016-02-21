#!/bin/bash
set -ex

cp /etc/profile.d/pocci /etc/profile.d/pocci.sh
POCCI_USER=`grep ":1000:" /etc/passwd | cut -d: -f1`
echo 'export POCCI_USER="'${POCCI_USER}'"' >>/etc/profile.d/pocci.sh
. /etc/profile.d/pocci.sh

cd $(dirname $0)

if [ -f /user_data/environment.sh ]; then
    cat /user_data/environment.sh | tr -d '\r' >/tmp/environment.sh
    . /tmp/environment.sh
fi

if [ -n "${on_provisioning_finished}" ]; then
    trap "${on_provisioning_finished}" EXIT
fi

./setup-timezone.sh
./setup-redmine_lang.sh
./setup-https.sh
./setup-proxy.sh
./setup-notifier.sh
./setup-backup.sh
./setup-postfix.sh
./setup-pocci.sh
./setup-crontab.sh
./setup-ntp.sh
./setup-hooks.sh
