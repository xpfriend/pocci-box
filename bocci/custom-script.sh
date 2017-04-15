#!/bin/bash
set -eux

DOCKER_COMPOSE_VERSION=1.11.2

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
apt-get install -y apt-transport-https atsar ca-certificates git \
        linux-image-extra-$(uname -r) linux-image-extra-virtual mailutils \
        software-properties-common ssmtp zabbix-agent
initctl stop zabbix-agent
mv /etc/init/zabbix-agent.conf /etc/init/zabbix-agent

groupadd docker
usermod -aG docker ${SSH_USERNAME}
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update
apt-get install -y docker-ce
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
