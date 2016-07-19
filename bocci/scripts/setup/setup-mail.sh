#!/bin/bash
set -ex

SSMTP_CONF=/etc/ssmtp/ssmtp.conf

if [ -f ${SSMTP_CONF}.backup ]; then
    cp ${SSMTP_CONF}.backup ${SSMTP_CONF}
else
    cp ${SSMTP_CONF} ${SSMTP_CONF}.backup
fi

echo "FromLineOverride=YES" >> ${SSMTP_CONF}

if [ -n "${smtp_relayhost}" ]; then
    echo 'export SMTP_RELAYHOST="'${smtp_relayhost}'"' >>/etc/profile.d/pocci.sh

    smtp_relayhost_plain=`echo ${smtp_relayhost} | sed -E 's/\[|\]//g'`
    sed -E "s/^mailhub=.*$/mailhub=${smtp_relayhost_plain}/g" -i ${SSMTP_CONF}
else
    sed -E "s/^mailhub=.*$/mailhub=localhost/g" -i ${SSMTP_CONF}
fi

if [ -n "${smtp_password}" ]; then
    echo 'export SMTP_PASSWORD="'${smtp_password}'"' >>/etc/profile.d/pocci.sh

    smtp_password_user=`echo ${smtp_password} | cut -d: -f1`
    smtp_password_pass=`echo ${smtp_password} | cut -d: -f2`
    echo "AuthUser=${smtp_password_user}" >> ${SSMTP_CONF}
    echo "AuthPass=${smtp_password_pass}" >> ${SSMTP_CONF}
    echo "UseTLS=YES" >> ${SSMTP_CONF}
    echo "UseSTARTTLS=YES" >> ${SSMTP_CONF}
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
