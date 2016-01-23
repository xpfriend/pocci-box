#!/bin/bash
set -ex

export SERVICE_TYPE="${service_type:-default}"
export POCCI_TEMPLATE="${template:-template}"
echo 'export POCCI_TEMPLATE="'${POCCI_TEMPLATE}'"' >>/etc/profile.d/pocci.sh

sudo -u ${POCCI_USER} -E -i bash <<EOF
set -ex
cd ${POCCI_DIR}/bin
echo 'y' | ./create-config ${SERVICE_TYPE}
./up-service
EOF

if [ -f /etc/init/pocci ]; then
    mv /etc/init/pocci /etc/init/pocci.conf
    initctl reload-configuration
fi
