#!/bin/bash
set -ex

cd $(dirname $0)

if [ -f /vagrant/environment.sh ]; then
    cat /vagrant/environment.sh | tr -d '\r' >/tmp/environment.sh
    . /tmp/environment.sh
fi

./setup-timezone.sh
./setup-redmine_lang.sh
./setup-proxy.sh
./setup-pocci.sh
