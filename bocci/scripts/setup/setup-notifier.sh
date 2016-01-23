#!/bin/bash
set -ex

echo 'export NOTIFIER="'mail'"' >>/etc/profile.d/pocci.sh

cat << EOF >/tmp/notifier-task-schedule.txt
11 * * * * ${RUNTIME_SCRIPTS_DIR}/watch-docker-process
12 * * * * ${RUNTIME_SCRIPTS_DIR}/watch-disk-usage
EOF
