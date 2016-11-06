#!/bin/bash
set -eux

DOCKER_COMPOSE_VERSION=1.8.1

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

export DEBIAN_FRONTEND=noninteractive
apt-get install -y apt-transport-https atsar ca-certificates git mailutils ssmtp zabbix-agent
initctl stop zabbix-agent
mv /etc/init/zabbix-agent.conf /etc/init/zabbix-agent

groupadd docker
usermod -aG docker ${SSH_USERNAME}
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-engine
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/' /etc/default/grub
update-grub


curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose

echo 'DOCKER_OPTS="'--log-opt max-size=10m --log-opt max-file=10'"' >>/etc/default/docker



echo 'export POCCI_BOX_DIR="'${POCCI_BOX_DIR}'"' >/etc/profile.d/pocci.sh
echo 'export RUNTIME_SCRIPTS_DIR="'${RUNTIME_SCRIPTS_DIR}'"' >>/etc/profile.d/pocci.sh
echo 'export POCCI_DIR="'${POCCI_BOX_DIR}/pocci'"' >>/etc/profile.d/pocci.sh

sudo -u ${SSH_USERNAME} -E -i bash <<BUILD
set -ex

git config --global user.email "${SSH_USERNAME}@localhost.localdomain"
git config --global user.name "Pocci"

cd ${POCCI_BOX_DIR}
git clone https://github.com/xpfriend/pocci.git
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
