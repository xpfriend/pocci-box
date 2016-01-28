#!/bin/bash
set -ex

if [ -z "${ntp_server}" ]; then
    exit
fi

sed -i /etc/ntp.conf -e 's/^server/#server/g'
for i in ${ntp_server}; do
    echo "server $i" >>/etc/ntp.conf
done

service ntp restart
