#!/bin/bash
set -ex

if [ -n "${smtp_relayhost}" ]; then
    echo 'export SMTP_RELAYHOST="'${smtp_relayhost}'"' >>/etc/profile.d/pocci.sh
fi

if [ -n "${smtp_password}" ]; then
    echo 'export SMTP_PASSWORD="'${smtp_password}'"' >>/etc/profile.d/pocci.sh
fi

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
