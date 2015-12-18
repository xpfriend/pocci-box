#!/bin/bash
set -ex

export SERVICE_TYPE="${service_type:-default}"

sudo -u vagrant -E -i bash <<EOF
set -ex
export KANBAN_REPOSITORY=/home/vagrant/kanban/.git
if [ -f /vagrant/${SERVICE_TYPE}.yml ]; then
    cp /vagrant/${SERVICE_TYPE}.yml ~/pocci/template/setup.${SERVICE_TYPE}.yml
fi

cd ~/pocci/bin
if [ -f ~/pocci/template/setup.${SERVICE_TYPE}.yml ]; then
    ./create-config ${SERVICE_TYPE}
    ./up-service
else
    cp ~/pocci/template/setup.default.yml ~/pocci/template/setup.${SERVICE_TYPE}.yml
    ./lib/start-document-server
fi
EOF

mv /etc/init/pocci /etc/init/pocci.conf
initctl reload-configuration
