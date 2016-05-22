#!/bin/bash
set -ex

MAIN_CF=/etc/postfix/main.cf
PASSWORD_FILE=/etc/postfix/smtp_password

if [ -f ${MAIN_CF}.backup ]; then
    cp ${MAIN_CF}.backup ${MAIN_CF}
else
    cp ${MAIN_CF} ${MAIN_CF}.backup
fi

sed -E 's|^mynetworks.+$|\0 172.17.0.0/16|' -i ${MAIN_CF}
sed -E 's|^mydestination.+$|\0, example.com, example.net|' -i ${MAIN_CF}

if [ -n "${smtp_relayhost}" ]; then
    sed -E "s|(relayhost =)(.*)|\1 ${smtp_relayhost}|" -i ${MAIN_CF}

    if [ -n "${smtp_password}" ]; then
        echo "${smtp_relayhost} ${smtp_password}" >${PASSWORD_FILE}
        chmod 400 ${PASSWORD_FILE}
        postmap hash:${PASSWORD_FILE}

        echo "smtp_tls_security_level = may" >>${MAIN_CF}
        echo "smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt" >>${MAIN_CF}
        echo "smtp_sasl_auth_enable = yes" >>${MAIN_CF}
        echo "smtp_sasl_security_options = noanonymous" >>${MAIN_CF}
        echo "smtp_sasl_password_maps = hash:${PASSWORD_FILE}" >>${MAIN_CF}
    fi
fi

/etc/init.d/postfix reload

ADMIN_MAIL_ADDRESS=${admin_mail_address}
if [ -z "${ADMIN_MAIL_ADDRESS}" ]; then
    ADMIN_MAIL_ADDRESS=${POCCI_USER}@localhost.localdomain
fi
export ADMIN_MAIL_ADDRESS
echo 'export ADMIN_MAIL_ADDRESS="'${ADMIN_MAIL_ADDRESS}'"' >>/etc/profile.d/pocci.sh

ALIASES=/etc/aliases
if [ -f ${ALIASES}.backup ]; then
    cp ${ALIASES}.backup ${ALIASES}
else
    cp ${ALIASES} ${ALIASES}.backup
fi
echo "admin: ${ADMIN_MAIL_ADDRESS}" >>${ALIASES}
echo "boze: ${ADMIN_MAIL_ADDRESS}" >>${ALIASES}
echo "jenkins-ci: ${ADMIN_MAIL_ADDRESS}" >>${ALIASES}
newaliases

ALERT_MAIL_FROM=${alert_mail_from}
if [ -z "${ALERT_MAIL_FROM}" ]; then
    ALERT_MAIL_FROM=${ADMIN_MAIL_ADDRESS}
fi
echo 'export ALERT_MAIL_FROM="'${ALERT_MAIL_FROM}'"' >>/etc/profile.d/pocci.sh
