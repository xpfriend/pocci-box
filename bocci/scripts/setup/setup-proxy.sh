#!/bin/bash
set -ex

if [ -z "${http_proxy}" ]; then
    >/etc/profile.d/proxy.sh
    exit
fi

if [ -z "${https_proxy}" ]; then
    https_proxy="${http_proxy}"
fi

if [ -z "${ftp_proxy}" ]; then
    ftp_proxy="${http_proxy}"
fi

if [ -z "${rsync_proxy}" ]; then
    rsync_proxy="${http_proxy}"
fi

if [ -z "${no_proxy}" ]; then
    no_proxy="127.0.0.1,localhost"
fi

echo "export http_proxy=${http_proxy}" >/etc/profile.d/proxy.sh
echo "export https_proxy=${https_proxy}" >>/etc/profile.d/proxy.sh
echo "export ftp_proxy=${ftp_proxy}" >>/etc/profile.d/proxy.sh
echo "export rsync_proxy=${rsync_proxy}" >>/etc/profile.d/proxy.sh
echo "export no_proxy=${no_proxy}" >>/etc/profile.d/proxy.sh

cat /etc/profile.d/proxy.sh >>/etc/default/docker
service docker restart
