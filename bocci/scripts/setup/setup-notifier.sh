#!/bin/bash
set -ex

NOTIFIER=${notifier:-mail}
ZABBIX_SERVER=${zabbix_server:-127.0.0.1}

if [ -f /etc/init/zabbix-agent.conf ]; then
    initctl stop zabbix-agent
    rm /etc/init/zabbix-agent.conf
fi

echo 'export NOTIFIER="'${NOTIFIER}'"' >>/etc/profile.d/pocci.sh

if [ "${NOTIFIER}" = "zabbix" ]; then
    cp /etc/init/zabbix-agent /etc/init/zabbix-agent.conf
    sed -i /etc/zabbix/zabbix_agentd.conf \
        -e "s/^Server=.*$/Server=${ZABBIX_SERVER}/" \
        -e "s/^ServerActive=.*$/ServerActive=${ZABBIX_SERVER}/" \
        -e "s/^Hostname=.*$/Hostname=$(hostname)/"
    initctl start zabbix-agent
fi

cat << EOF >/tmp/notifier-task-schedule.txt
11 * * * * ${RUNTIME_SCRIPTS_DIR}/watch-docker-process
12 * * * * ${RUNTIME_SCRIPTS_DIR}/watch-disk-usage
EOF
