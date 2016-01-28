#!/bin/bash
set -ex

export BACKUP_DIR=${POCCI_BOX_DIR}/backup
echo 'export BACKUP_DIR="'${BACKUP_DIR}'"' >>/etc/profile.d/pocci.sh
echo 'export DAILY_BACKUP_NUM="'${daily_backup_num:-2}'"' >>/etc/profile.d/pocci.sh

export BACKUP_TYPE=${backup_type:-pretender}
echo 'export BACKUP_TYPE="'${BACKUP_TYPE}'"' >>/etc/profile.d/pocci.sh

if [ "${BACKUP_TYPE}" = "rsync" ]; then
    echo 'export BACKUP_SERVER="'${backup_server}'"' >>/etc/profile.d/pocci.sh
    echo 'export BACKUP_SERVER_USER="'${backup_server_user}'"' >>/etc/profile.d/pocci.sh
    echo 'export BACKUP_SERVER_DIR="'${backup_server_dir}'"' >>/etc/profile.d/pocci.sh
fi

set +e
mkdir ${BACKUP_DIR}
mkdir ${BACKUP_DIR}/daily
mkdir ${BACKUP_DIR}/timely
set -e
chown -R ${POCCI_USER}:${POCCI_USER} ${BACKUP_DIR}

if [ "${daily_backup_hour}" = "-" ]; then
    DISABLE_DAILY_BACKUP="#"
    unset daily_backup_hour
fi
if [ "${timely_backup_hour}" = "-" ]; then
    DISABLE_TIMELY_BACKUP="#"
    unset timely_backup_hour
fi

DAILY_BACKUP_HOUR="${daily_backup_hour:-0}"
TIMELY_BACKUP_HOUR="${timely_backup_hour:-10,12,18}"

cat << EOF >/tmp/backup-task-schedule.txt
${DISABLE_DAILY_BACKUP}0 ${DAILY_BACKUP_HOUR} * * * ${RUNTIME_SCRIPTS_DIR}/do-backup daily
${DISABLE_TIMELY_BACKUP}0 ${TIMELY_BACKUP_HOUR} * * * ${RUNTIME_SCRIPTS_DIR}/do-backup
EOF
