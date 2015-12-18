#!/bin/bash
set -ex

if [ -z "${http_proxy}" ]; then
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

echo "export http_proxy=${http_proxy}" >/tmp/proxy.env
echo "export https_proxy=${https_proxy}" >>/tmp/proxy.env
echo "export ftp_proxy=${ftp_proxy}" >>/tmp/proxy.env
echo "export rsync_proxy=${rsync_proxy}" >>/tmp/proxy.env
echo "export no_proxy=${no_proxy}" >>/tmp/proxy.env

cat /tmp/proxy.env >>/etc/bash.bashrc
cat /tmp/proxy.env >>/etc/default/docker
service docker restart
