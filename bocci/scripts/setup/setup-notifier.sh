#!/bin/bash
set -ex

echo 'export NOTIFIER="'mail'"' >>/etc/profile.d/pocci.sh

ADMIN_MAIL_ADDRESS=${admin_mail_address}
if [ -z "${ADMIN_MAIL_ADDRESS}" ]; then
    ADMIN_MAIL_ADDRESS=${POCCI_USER}@localhost.localdomain
fi
export ADMIN_MAIL_ADDRESS
echo 'export ADMIN_MAIL_ADDRESS="'${ADMIN_MAIL_ADDRESS}'"' >>/etc/profile.d/pocci.sh

ALERT_MAIL_FROM=${alert_mail_from}
if [ -z "${ALERT_MAIL_FROM}" ]; then
    ALERT_MAIL_FROM=${ADMIN_MAIL_ADDRESS}
fi
echo 'export ALERT_MAIL_FROM="'${ALERT_MAIL_FROM}'"' >>/etc/profile.d/pocci.sh

sudo -u ${POCCI_USER} -E /bin/bash <<'EOF'
set -ex
for i in ${POCCI_DIR}/template/*.yml; do
    sed -E "s|adminMailAddress:.*$|adminMailAddress: ${ADMIN_MAIL_ADDRESS}|g" -i $i
done
EOF

cat << EOF >/tmp/notifier-task-schedule.txt
11 * * * * ${RUNTIME_SCRIPTS_DIR}/watch-docker-process
12 * * * * ${RUNTIME_SCRIPTS_DIR}/watch-disk-usage
EOF
