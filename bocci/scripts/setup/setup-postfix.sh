#!/bin/bash
set -ex

MAIN_CF=/etc/postfix/main.cf
PASSWORD_FILE=/etc/postfix/smtp_password

sed -E 's|(mynetworks = 127.0.0.0/8 \[::ffff:127.0.0.0\]/104 \[::1\]/128)(.*)|\1 172.17.0.0/16|' -i ${MAIN_CF}

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
