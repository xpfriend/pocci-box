#!/bin/bash
set -ex

export POCCI_USER=`grep ":1000:" /etc/passwd | cut -d: -f1`
. /etc/profile.d/pocci.sh

cd $(dirname $0)

if [ -f /user_data/environment.sh ]; then
    cat /user_data/environment.sh | tr -d '\r' >/tmp/environment.sh
    . /tmp/environment.sh
fi

./setup-timezone.sh
./setup-redmine_lang.sh
./setup-proxy.sh
./setup-postfix.sh
./setup-pocci.sh
