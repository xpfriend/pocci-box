#!/bin/bash
set -ex

export SERVICE_TYPE="${service_type:-default}"
export POCCI_TEMPLATE="${template:-template}"
POCCI_DOMAIN_NAME="${domain:-pocci.test}"
echo 'export POCCI_TEMPLATE="'${POCCI_TEMPLATE}'"' >>/etc/profile.d/pocci.sh
echo 'export POCCI_DOMAIN_NAME="'${POCCI_DOMAIN_NAME}'"' >>/etc/profile.d/pocci.sh

sudo -u ${POCCI_USER} -E -i bash <<EOF
set -ex
cd ${POCCI_DIR}/bin
echo 'y' | ./create-service ${SERVICE_TYPE}
EOF

if [ -f /etc/init/pocci ]; then
    mv /etc/init/pocci /etc/init/pocci.conf
    initctl reload-configuration
fi
