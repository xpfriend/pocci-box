#!/bin/bash
set -eux

DOCKER_COMPOSE_VERSION=1.7.1

export SETUP_SCRIPTS_DIR=/root/scripts
export POCCI_BOX_DIR=/opt/pocci-box
export RUNTIME_SCRIPTS_DIR=${POCCI_BOX_DIR}/scripts

mkdir ${SETUP_SCRIPTS_DIR}
mv /home/${SSH_USERNAME}/scripts/setup/* ${SETUP_SCRIPTS_DIR}
chmod +x ${SETUP_SCRIPTS_DIR}/*

mkdir -p ${RUNTIME_SCRIPTS_DIR}
mv /home/${SSH_USERNAME}/scripts/runtime/* ${RUNTIME_SCRIPTS_DIR}
chmod +x ${RUNTIME_SCRIPTS_DIR}/*
chown -R ${SSH_USERNAME}:${SSH_USERNAME} ${POCCI_BOX_DIR}
rm -fr /home/${SSH_USERNAME}/scripts

curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose

echo 'DOCKER_OPTS="'--log-opt max-size=10m --log-opt max-file=10'"' >>/etc/default/docker

export DEBIAN_FRONTEND=noninteractive
apt-get install -y atsar git mailutils postfix zabbix-agent
initctl stop zabbix-agent
mv /etc/init/zabbix-agent.conf /etc/init/zabbix-agent

echo 'export POCCI_BOX_DIR="'${POCCI_BOX_DIR}'"' >/etc/profile.d/pocci.sh
echo 'export RUNTIME_SCRIPTS_DIR="'${RUNTIME_SCRIPTS_DIR}'"' >>/etc/profile.d/pocci.sh
echo 'export POCCI_DIR="'${POCCI_BOX_DIR}/pocci'"' >>/etc/profile.d/pocci.sh
echo 'export KANBAN_REPOSITORY="'${POCCI_BOX_DIR}/kanban/.git'"' >>/etc/profile.d/pocci.sh

sudo -u ${SSH_USERNAME} -E -i bash <<BUILD
set -ex

git config --global user.email "`whoami`@localhost.localdomain"
git config --global user.name "Pocci"

cd ${POCCI_BOX_DIR}
git clone https://github.com/xpfriend/pocci.git
git clone https://github.com/leanlabsio/kanban.git
cd pocci/bin
./build
./lib/stop-document-server
./pull-all-images
BUILD

cat << EOF >/etc/init/pocci
description "Pocci"
start on started docker
stop on stopping docker
kill timeout 120
exec sudo -u ${SSH_USERNAME} -E -i /bin/bash ${RUNTIME_SCRIPTS_DIR}/start
EOF

cp /etc/profile.d/pocci.sh /etc/profile.d/pocci
