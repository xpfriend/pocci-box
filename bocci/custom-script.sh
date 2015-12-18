#!/bin/bash
set -eux

DOCKER_COMPOSE_VERSION=1.5.1

chmod +x /home/${SSH_USERNAME}/scripts/*
mkdir /root/scripts
mv /home/${SSH_USERNAME}/scripts/setup* /root/scripts

curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose

export DEBIAN_FRONTEND=noninteractive
apt-get install -y expect git mailutils postfix

sudo -u ${SSH_USERNAME} -E -i bash <<BUILD
set -ex

git config --global user.email "pocci@example.com"
git config --global user.name "Pocci"

git clone https://github.com/xpfriend/pocci.git
git clone https://github.com/leanlabsio/kanban.git
echo "export KANBAN_REPOSITORY=/home/${SSH_USERNAME}/kanban/.git" >>/home/${SSH_USERNAME}/.bashrc
cd pocci/bin
./pull-all-images
./build
BUILD

cat << EOF >/etc/init/pocci
description "Pocci"
start on started docker
stop on runlevel [!2345]
kill timeout 120
exec sudo -u ${SSH_USERNAME} -E -i /bin/bash /home/${SSH_USERNAME}/scripts/start
EOF
