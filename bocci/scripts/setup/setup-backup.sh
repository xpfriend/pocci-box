#!/bin/bash
set -ex

export BACKUP_DIR=${POCCI_BOX_DIR}/backup
echo 'export BACKUP_DIR="'${BACKUP_DIR}'"' >>/etc/profile.d/pocci.sh
echo 'export DAILY_BACKUP_NUM="'${daily_backup_num:-2}'"' >>/etc/profile.d/pocci.sh

BACKUP_TYPE=${backup_type:-pretender}
if [ "${BACKUP_TYPE}" = "rsync" ]; then
    echo 'export BACKUP_SERVER="'${backup_server}'"' >>/etc/profile.d/pocci.sh
    echo 'export BACKUP_SERVER_USER="'${backup_server_user}'"' >>/etc/profile.d/pocci.sh
    echo 'export BACKUP_SERVER_DIR="'${backup_server_dir}'"' >>/etc/profile.d/pocci.sh
fi
cp -p ${RUNTIME_SCRIPTS_DIR}/push-backup-files-by-${BACKUP_TYPE} ${RUNTIME_SCRIPTS_DIR}/push-backup-files
cp -p ${RUNTIME_SCRIPTS_DIR}/pull-backup-files-by-${BACKUP_TYPE} ${RUNTIME_SCRIPTS_DIR}/pull-backup-files

set +e
mkdir ${BACKUP_DIR}
mkdir ${BACKUP_DIR}/daily
mkdir ${BACKUP_DIR}/timely
set -e
chown -R ${POCCI_USER}:${POCCI_USER} ${BACKUP_DIR}

cat << EOF >/tmp/backup-task-schedule.txt
0 ${daily_backup_hour:-0} * * * ${RUNTIME_SCRIPTS_DIR}/do-backup daily
0 ${timely_backup_hour:-10,12,18} * * * ${RUNTIME_SCRIPTS_DIR}/do-backup
EOF
