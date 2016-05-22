#!/bin/bash
set -ex

export TIMEZONE="${timezone:-Etc/UTC}"

timedatectl set-timezone "${TIMEZONE}"
initctl restart cron

echo 'export TZ="'${TIMEZONE}'"' >>/etc/profile.d/pocci.sh
