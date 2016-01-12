#!/bin/bash
set -ex

export SERVICE_TYPE="${service_type:-default}"

sudo -u ${POCCI_USER} -E -i bash <<EOF
set -ex
if [ -f /user_data/setup.${SERVICE_TYPE}.yml ]; then
    cp /user_data/setup.${SERVICE_TYPE}.yml ${POCCI_DIR}/template
fi

cd ${POCCI_DIR}/bin
if [ -f ${POCCI_DIR}/template/setup.${SERVICE_TYPE}.yml ]; then
    echo 'y' | ./create-config ${SERVICE_TYPE}
    ./up-service
else
    cp ${POCCI_DIR}/template/setup.default.yml ${POCCI_DIR}/template/setup.${SERVICE_TYPE}.yml
    ./lib/start-document-server
fi
EOF

if [ -f /etc/init/pocci ]; then
    mv /etc/init/pocci /etc/init/pocci.conf
    initctl reload-configuration
fi
