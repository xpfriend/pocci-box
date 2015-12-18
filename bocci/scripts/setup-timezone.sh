#!/bin/bash
set -ex

if [ -z "${timezone}" ]; then
    exit
fi

timedatectl set-timezone "${timezone}"
initctl restart cron
